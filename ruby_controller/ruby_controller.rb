#!/usr/bin/env ruby

require "serialport"
require "json"
require "net/http"

if ARGV.length != 5
  puts "error: five arguments must be provided"
  puts
  puts "Usage:"
  puts "  ./ruby_controller.rb port job hudson_host user password"
  puts
  puts "Example:"
  puts "  ./ruby_controller.rb /dev/ttyACM0 project-trunk hudson.company.com"
  puts "                       johndoe 123456"
  exit 1
end

# parse params
port = ARGV[0]
job_name = ARGV[1]
host = ARGV[2]
user = ARGV[3]
password = ARGV[4]

# params for serial port
baud_rate = 9600
data_bits = 8
stop_bits = 1
parity = SerialPort::NONE

sp = SerialPort.new(port, baud_rate, data_bits, stop_bits, parity)

# wait for initialization
sleep(2)

# prepare HTTPS connection
http = Net::HTTP.new(host, 443)
http.use_ssl = true
http.verify_mode = OpenSSL::SSL::VERIFY_NONE

while true
  data = nil

  # do the request
  http.start do |http|
    req = Net::HTTP::Get.new('/api/json')
    req.basic_auth user, password

    response = http.request(req)

    if response.code == "401"
      puts "error: given credentials are not valid; server responded with 401."
      exit 1
    end

    data = response.body
  end

  # convert returned JSON data to Ruby hash
  result = JSON.parse(data)

  # find tracked job
  tracked_job = nil
  result['jobs'].each do |job|
    if job['name'] == job_name
      tracked_job = job
    end
  end

  if tracked_job == nil
    puts "error: job '" + job_name + "' not found"
    exit 1
  end

  # resolve state
  state = 1 # green

  if tracked_job['color'] =~ /anime/
    state = 7 # all colors
   end

  sp.write(state)
  
  sleep(5)
end

sp.close
