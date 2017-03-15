class Weather < DynamicContent
  DISPLAY_NAME = 'Weather'

  UNITS = {
    'metric' => 'Celsius',
    'imperial' => 'Fahrenheit'
  }

  FONTS = {
    'owf' => 'Open Weather Font',
    'wi' => 'Weather Icons'
  }

  FORECAST = {
    'realtime' => 'Realtime Weather',
    'forecast' => 'Max and Min temps forecast for the day'
  }

  validate :validate_config

  def build_content
    require 'net/http'
    require 'nokogiri'
    require 'base64'
    require 'json'

    container="<head id='Head1'><meta diego='utf89'/><meta http-equiv='Content-Type' content='text/html; charset=utf-8' />
        <meta name='viewport' content='width=device-width, user-scalable=yes' />
        <link rel='stylesheet' type='text/css' href='http://www.aa2000.com.ar/stylesheets/screen.min.css' />
        <link rel='stylesheet' type='text/css' href='http://www.aa2000.com.ar/stylesheets/menu-fullscreen.min.css' />
        <link rel='stylesheet' type='text/css' href='http://www.aa2000.com.ar/stylesheets/aeropuerto.min.css' />
        <style>
            .vuelos-tabla table.scrollvuelos-main tbody.minitable {
                display: block;
                height: 100%
            }
        </style>
        </head>
        <body id='intro' class='intro-aep'>
          <div class='vuelos-tabla' id='vuelos-tabla'>
          </div>
        </div>
        </body>
    </html>"
    
    puts "------------------------------container--------------------------------------"
    puts container.encoding

    #uri= URI.parse('http://www.aa2000.com.ar/' + self.config['airport'])
    uri= URI.parse('http://www.aa2000.com.ar/ezeiza')

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.path, initheader = {'X-MicrosoftAjax' => 'Delta=true', 'User-Agent' => 'Mozilla/5.0'})

    #if self.config[':flight_type'] == 'a'
    #  req.set_form_data( {'__EVENTTARGET' => 'CargarGrillaTimer'} )
    #  flightsDivId='#arribos'
    #else
      req.set_form_data( {'__EVENTTARGET' => 'CargarGrillaTimer', 'chkDivPartidas' => 'true'} )
      flightsDivId='#partidas'
    #end

    res=http.request(req)
    puts "---------------------res-------------------" + res['content-type']
    res.body.force_encoding('utf-8')
    puts "----body---- " 
    puts res.body.encoding
    body=res.body.split('|')[7]
    body.gsub!(/\r/, " ").gsub!(/>\s*</, "><")
    puts "---------------------body-------------------" 
    puts  body.encoding

    parsedBody=Nokogiri::HTML::fragment(body)

    containerNoko=Nokogiri::HTML(container.encode('utf-8'))
    containerNoko.at('#vuelos-tabla').add_child(parsedBody.css(flightsDivId))


    html=containerNoko.to_s
    puts "----------------html-------------"
    puts html.encoding


    # Create HtmlText content
    iframe = Iframe.new()
    iframe.name = "Vuelos ezeiza}"
    iframe.data = JSON.dump( 'url' => "data:text/html;charset=utf-8;base64, " + Base64.strict_encode64(html))

    return [iframe]
  end

  # Weather needs a location.  Also allow specification of units
  def self.form_attributes
    attributes = super()
    attributes.concat([:config => [:lat, :lng, :units, :font_name, :location_name, :format_string, :forecast_type]])
  end

  def validate_config
    if self.config['lat'].blank? || self.config['lng'].blank?
      errors.add(:base, 'A city must be selected')
    end
  end
end
