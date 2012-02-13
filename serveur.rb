require 'socket'
port = 8080
server = TCPServer.open(port)
process_number = 1
trap('EXIT'){ server.close }
process_number.times do
  fork do
    trap('INT'){ exit }
    loop do
      socket = server.accept
      puts "serving!"
      
      #request parsing
      firstLine = socket.gets
      if firstLine.nil?
next
      end
      tab = firstLine.split(' ')
      
      ope = tab[0]
      res = tab[1]
      ver = tab[2]
      
      getLine = "vide"
      getParams = {}
      tab = res.split('?')
      if not tab[1].nil?
getLine = tab[1]
tab = getLine.split('&')
tab.each do |e|
name, value = e.split('=')
getParams[name] = value
end
      end
      
      headers = {}
      while not (line = socket.gets).strip.empty? do
name, value = line.split(':')
headers[name.strip] = value.strip
      end
      
      postLine = "vide"
      postParams = {}
      if ope=="POST" and not headers["Content-Length"].nil?
length = headers["Content-Length"].to_i
data = socket.read(length)
if data.is_a?(String)
postLine = data
tab = postLine.split('&')
tab.each do |e|
name, value = e.split('=')
postParams[name] = value
end
end
      end
      
      #response
      html = "<ul>"
      html += "<li>Operation: "+ope+"</li>"
      html += "<li>Ressource: "+res+"</li>"
      html += "<li>Version: "+ver+"</li>"
      
      headers.each do |key, value|
html += "<li>"+key+": "+value+"</li>"
      end
      
      html += "<li>Get-Line: "+getLine+"</li>"
      if not getParams.empty?
html += "<ul>"
getParams.each do |key, value|
value = "nil" unless not value.nil?
html += "<li>"+key+": "+value+"</li>"
end
html += "</ul>"
end
      
      html += "<li>Post-Line: "+postLine+"</li>"
      if not postParams.empty?
html += "<ul>"
postParams.each do |key, value|
value = "nil" unless not value.nil?
html += "<li>"+key+": "+value+"</li>"
end
html += "</ul>"
end
      
      html += "</ul>"
      
      #response code
      socket.puts("200 HTTP/1.1 OK")
      
      #response headers
      line = "<html><h1>Serveur HTTP Ruby</h1><form action=\"\" method=\"POST\"><input type=\"text\" name=\"field\"/><input type=\"submit\"/><p>"+html+"</p></html>"
      
      socket.puts("Connection: close")
      socket.puts("Content-Length: #{line.length}")
      socket.puts
      
      #response body
      socket.puts(line)
      
      socket.close
    end
    exit
  end
end
trap('INT') { puts "\nexiting" ; exit }

# on attend la fin des fils
Process.waitall
