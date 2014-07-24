require "slack/api/version"
require "slack/api/multipart"
require "net/http"
require "json"


module Slack
  module Api
    class Wrapper
      def initialize(token)
        raise "set your api token"  unless token
        @root_url = 'https://slack.com/api'
        @token = token
      end

      def users_list
        _submit('users.list');
      end

      def channels_info(channel)
        _submit('channels.info', {'channel' => channel})
      end

      def channels_join(name)
        _submit('channels.join', {'name' => name})
      end

      def channels_leave(channel)
        _submit('channels.leave', {'channel' => channels})
      end

      def channels_history(channel, latest = nil, oldest = nil, count = nil)
        _submit('channels.history', {
          'channel' => channel,
          'latest' => latest,
          'oldest' => oldest,
          'count' => count
        })
      end

      def channels_mark(channel, ts)
        _submit('channels.mark', {
          'channel' => channel,
          'ts' => ts,
        })
      end

      def channels_invite(channel, user)
        _submit('channels.invite', {
          'channel' => channel,
          'user' => user
        })
      end

      def channels_list(exclude_archived = nil)
        _submit('channels.list', {'exclude_archived' => exclude_archived})
      end

      def files_upload(filepath = nil, content = nil, filetype = nil, filename = nil, title = nil, initial_comment = nil, channels = nil)

        params = _params({
            'content' => content,
            'filetype' => filetype,
            'filename' => filename,
            'title' => title,
            'initial_comment' => initial_comment,
            'channels' => channels
        })

        if filepath.nil? && ! content.nil?
          params['file'] = nil
          return _submit('files.upload', params)
        end

        params['file'] = {
          'filepath' => filepath
        }

        url = _url('files.upload')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.start do |http|
          req = Net::HTTP::Post.new(url.path)
          form_data = Slack::Api::Multipart.new(params)
          req.body_stream = form_data
          req["Content-Length"] = form_data.size
          req["Content-Type"] = form_data.content_type
          return http.request(req)
        end
      end

      def files_list(user = nil, ts_from = nil, ts_to = nil, types = nil, count = nil, page = nil)
        _submit('files.list', {
          'user' => user,
          'ts_from' => ts_from,
          'ts_to' => ts_to,
          'types' => types,
          'count' => count,
          'page' => page,
        })
      end

      def files_info(file, count = nil, page = nil)
        _submit('files.info', {
          'file' => file,
          'count' => count,
          'page' => page
        })
      end

      def im_history(channel, latest = nil, oldest = nil, count = nil)
        _submit('im.history', {
          'channel' => channel,
          'latest' => latest,
          'oldest' => oldest,
          'count' => count
        })
      end

      def im_list
        _submit('im.list')
      end

      def groups_history(channel, latest = nil, oldest = nil, count = nil)
        _submit('groups.history', {
          'channel' => channel,
          'latest' => latest,
          'oldest' => oldest,
          'count' => count
        })
      end

      def groups_list(exclude_archived = nil)
        _submit('groups.list', {'exclude_archived' => exclude_archived})
      end

      def search_all(query, sort = nil, sort_dir = nil, highlight = nil, count = nil, page = nil)
        _submit('search.all', {
          'query' => query,
          'sort' => sort,
          'sort_dir' => sort_dir,
          'highlight' => highlight,
          'count' => count,
          'page' => page,
        })
      end

      def search_files(query, sort = nil, sort_dir = nil, highlight = nil, count = nil, page = nil)
        _submit('search.files', {
          'query' => query,
          'sort' => sort,
          'sort_dir' => sort_dir,
          'highlight' => highlight,
          'count' => count,
          'page' => page,
        })
      end

      def search_messages(query, sort = nil, sort_dir = nil, highlight = nil, count = nil, page = nil)
        _submit('search.messages', {
          'query' => query,
          'sort' => sort,
          'sort_dir' => sort_dir,
          'highlight' => highlight,
          'count' => count,
          'page' => page,
        })
      end

      def chat_postMessage(channel, text, username = nil, parse = nil, link_names = nil, attachments = nil, unfurl_links = nil, icon_url = nil, icon_emoji = nil)
        _submit('chat.postMessage', {
          'chennel' => channel,
          'text' => text,
          'username' => username,
          'parse' => parse,
          'link_names' => link_names,
          'attachments' => attachments,
          'unfurl_links' => unfurl_links,
          'icon_url' => icon_url,
          'icon_emoji' => icon_emoji,
        })
      end

      def stars_list(user = nil, count = 100, page = nil)
        _submit('stars.list', {
          'user' => user,
          'count' => count,
          'page' => page,
        })
      end

      def auth_test
        _submit('auth.test')
      end

      def emoji_list
        _submit('emoji.list')
      end

      def _submit(url, params = {})
        JSON.parse(
          Net::HTTP.post_form(_url(url), _params(params)).body
        )
      end

      def _url(url)
        URI(@root_url + '/' + url)
      end

      def _params(params = {})
        params['token'] = @token
        params
      end
    end
  end
end
