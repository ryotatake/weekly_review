require 'open-uri'
require 'json'

class Todoist
  attr_accessor :items

  API_URL = 'https://todoist.com/api/v7/'
  TOKEN   = ENV['TODOIST_TOKEN'] # ~/.bash_profileに設定
  LIMIT   = 50

  def initialize
    @items = []
  end

  def get_completed_items(offset: 0, since: Date.today)
    # sinceにdateオブジェクトを渡す際には、システム側か環境変数でタイムゾーンを日本にしておくこと。

    acquired_items = request_completed_items(offset: offset, since: since)

    if acquired_items.count > 0
      @items += acquired_items
      offset += LIMIT
      get_completed_items(offset: offset, since: since)
    else
      @items
    end
  end

  private

    def self.parse_japanese_date(date_localtime_ja)
      # Todoistの時刻のフォーマットは `YYYY-MM-DDT00:00`
      # Todoistの標準では標準時刻が使われているので、時差分を引く。

      time_difference = 9
      parsed_date     = (date_localtime_ja - 1).to_s
      parsed_time     = "T#{24 - time_difference}:00"
      parsed_datetime = parsed_date + parsed_time
    end

    def request_completed_items(offset: 0, since: nil)
      _since          = Todoist.parse_japanese_date(since)
      params          = create_params(offset, _since)
      request_url     = create_url("completed/get_all", params)
      response_json   = api_request(request_url)
      completed_items = response_json["items"]
    end

    def create_params(offset, since)
      params          = {token: TOKEN, limit: LIMIT}
      params[:offset] = offset
      params[:since]  = since if since
      params
    end
    
    def create_url(action, params)
      url = API_URL + action + '?' + URI.encode_www_form(params)
    end

    def api_request(request_url)
      response = open(request_url)
      response_code, response_message = response.status

      if response_code == "200"
        JSON.parse(response.read)
      else
        #FIXME: エラーハンドリングちゃんとやる
        puts "取得に失敗しました。 response_message: #{response_message}"
      end
    end
end