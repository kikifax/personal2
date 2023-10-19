module Darebee
  require 'date'
  require 'open-uri'
  require 'fileutils'

  ButtonNum=10
  @@dates=0
  @@start=Date.today
  @@instance="" unless defined?(@@instance)

  Image_folder="public/darebee"

  def self.setInstance(i)
    print :instance
    p @@instance=i
  end

  def self.addDate(date)
    p [:addDate,date]
    date=Date.parse(date) if date.is_a?(String)
    File.open(__dir__+"/exercise#{@@instance==1 ? ?1 : ''}.txt", 'a+') {_1.puts Date.today.strftime('%Y%m%d')+":::DD"+date.strftime('%Y%m%d') }

    #puts "addDate #{date} #{@@dates}"
    if date<@@start
      diff=@@start-date
      p [1,date,@@start,diff]
      @@dates<<=diff
      @@dates|=1
      @@start=date
      p [1.1,date,@@start,diff]
    else
      p [2,date,@@start,date-@@start]
      @@dates|=1<<(date-@@start)
    end
    saveDates
    #puts "addDate exit #{[@@start,@@dates.to_s(2)]}"
  end

  def self.saveDates
    #@@dates=0; @@start=Date.today
    return if @@dates==0
    p [:save,@@instance,"bit_length:#{@@dates.bit_length}"]
    File.rename(__dir__+"/dates#{@@instance}.dat",__dir__+"/dates#{@@instance}_#{DateTime.now.to_time.to_i.to_s(36)}.dat")
    file = File.open(__dir__+"/dates#{@@instance}.dat", 'w')
    file.write(@@start)
    file.write(@@dates.digits(256).reverse.map(&:chr).join)
    file.close
  end

  def self.loadDates
    p [:load,self.object_id]
    f = File.read(__dir__+"/dates#{@@instance}.dat")
    @@start=Date.parse(f[0,10]) rescue nil
    exit if !@@start
    @@dates=0
    f[10..].bytes do |b|
      @@dates<<=8
      @@dates|=b
    end
    puts [:endload, @@start,@@dates.to_s(2),@@start+@@dates.digits(2).size,@@dates.to_s(2)[0,10],@@dates.to_s(2)[-10..]]
  end

  def self.getDates
    p [:getDates,@@start]
    r=[]
    diff=(Date.today-@@start).to_i
    (0..).find do |i|
      index=diff-i
      r<<index if @@dates&(1<<index)==0
      r.size==ButtonNum
    end
    r
  end

  def self.scrape_image(url)
    url=~/\d{4}/
    y=$&
    #p [:scrape,url,$&]
    filename = $&+File.basename(url)
    file_path = File.join(Image_folder, filename)
    if File.exist?(file_path)
      #puts "File #{filename} already exists."
    else
      File.open(file_path, 'wb') do |fo|
        fo.write open(url, 'rb').read
      end
      #puts "File #{filename} downloaded and saved."
    end
    
  end


  def self.getButtons

    loadDates
    
    p [:getButtons,self.object_id]
    p :getButtons2,@@dates
    
    returnString=""
    getDates.each do |i|
      date=@@start+i
      Thread.new { scrape_image("https://darebee.com/images/exercise/#{date.year}/#{date.strftime("%B").downcase}#{date.day}.gif") }
      p date
      p date.to_s
      #img_url="https://darebee.com/images/exercise/#{date.year}/#{date.strftime("%B").downcase}#{date.day}.gif"
      params="'#{date.year}','#{date.strftime("%B").downcase}','#{date.day}'"
      returnString+="<button class=\"dateButton\" onclick=\"dateFunc(#{params})\">#{date.to_s}</button>\n"
    end

    returnString
  end


  def self.loadFirst
    date=@@start+(getDates.first||0)
    p [:loadFirst,getDates,date]
    m=date.strftime("%B")
    returnString = "<span class=\"dateSpan\">#{date.day}.#{m[0].upcase + m[1..-1]} #{date.year}</span><br><br>"
    returnString+="<img src=\"/darebee/#{date.year}#{date.strftime("%B").downcase}#{date.day}.gif\" style=\"width:100%; height:100%;\">"
    returnString+="<br><button class=\"doneButton\" onclick=\"doneFunc('#{date.year}-#{date.strftime("%B").downcase}-#{date.day}')\">Erledigt!</button>\n"
    
  end

  def self.readExercises
    @@instance==?2
    p [:readExercises,@@instance]
    File.read(__dir__+"/exercise.txt").scan(/(?<=DD)\d+/).each do |l|
      addDate(l)
    end
  end

  def self.numExString
    p "#{@@dates.digits(2).sum} Übungen erledigt 😃"
  end

end
