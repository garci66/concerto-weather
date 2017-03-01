module ConcertoWeather
  class SearchController < ConcertoWeather::ApplicationController
    def find_city
      @results = getOpenWeatherCities(params[:q])

      respond_to do |format|
        format.js { render json: @results }
      end
    end

    private
      def getOpenWeatherCities(query)
        require 'net/http'
        require 'json'
        require 'erb'

        query_url=ERB::Util.url_encode(query)
        appid = ConcertoConfig["open_weather_map_api_key"]
        url = "http://api.openweathermap.org/data/2.5/find?q=#{query_url}&type=like&mode=json&appid=#{appid}"
        return Net::HTTP.get(URI(url))
      end
  end
end
