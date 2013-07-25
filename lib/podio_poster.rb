module Podio
  class Poster
    def setup_client(app_id, app_token)
      podio_client = Podio::Client.new({
        :api_key => ENV["PODIO_CLIENT_ID"],
        :api_secret => ENV["PODIO_CLIENT_SECRET"]
      })
      podio_client.authenticate_with_app(app_id, app_token)

      podio_client
    end
  end

  class BugPoster < Poster
    def initialize(app_id, app_token)
      @podio_client = setup_client(app_id, app_token)
    end

    def process(commits)
      commits.each do |commit|
        next if commit.blank?

        commit.each do |item_id, data|
          update_item_on_podio(item_id, data[:action], data[:comment])
        end
      end
    end

    def update_item_on_podio(item_id, cmd, comment)
      return unless ticket_does_exist?(item_id)
      return unless [:cmd_close, :cmd_ref].include?(cmd)

      add_comment_to_item(item_id, comment)
      set_status_to_fixed(item_id) if cmd == :cmd_close
    end

    def add_comment_to_item(item_id, comment)
      @podio_client.connection.post do |req|
        req.url "/comment/item/#{item_id}"
        req.body = {:value => comment}
      end
    end

    def set_status_to_fixed(item_id)
      fields = []
      fields << {:external_id => 'status', :values => [{'value' => 'Fixed'}]}

      @podio_client.connection.put do |req|
        req.url "/item/#{item_id}/value"
        req.body = fields
      end
    end

    def ticket_does_exist?(ticket_id)
      @podio_client.connection.get("/item/#{ticket_id}").status == 200
    rescue Podio::AuthorizationError
      false
    end
  end
end
