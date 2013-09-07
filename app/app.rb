module Octomaps
  class App < Padrino::Application
	register SassInitializer
	use ActiveRecord::ConnectionAdapters::ConnectionManagement
	register Padrino::Rendering
	register Padrino::Mailer
	register Padrino::Helpers
	# register Padrino::Sprockets
 #  sprockets :minify => (Padrino.env == :production)

	enable :sessions

	get :index do
	  render 'public/home'
	end

	get :notfound do
	  render 'public/notfound'
	end

	get :map do
		repo_name = "#{params[:owner]}/#{params[:repo]}".strip
		git_repo = GithubRepositoryService.new(repo_name)
		if git_repo.github_repository
			git_repo.update_database_based_upon_github
			@repo = git_repo.db_repo
			if params[:city]
				@location_count_hash = @repo.hash_of_cities_and_count
				opts = { :displayMode => 'markers', :region => 'world', :legend => 'none',
              :colors => ['FF8F86', 'C43512']}
			elsif params[:country]
				@location_count_hash = @repo.hash_of_countries_and_count
				opts = { :displayMode => 'region', :region => 'world', :legend => 'none',
             :colors => ['FF8F86', 'C43512']}
			end
			markers = Map.new(@location_count_hash).markers
     	@chart_markers = GoogleVisualr::Interactive::GeoChart.new(markers, opts)
     	@list = @location_count_hash.sort_by{|location, contributors| contributors}.reverse
			@repo.reload
			render 'public/map'
		else 
			redirect_to :notfound
		end
	end


	##
	# Caching support
	#
	# register Padrino::Cache
	# enable :caching
	#
	# You can customize caching store engines:
	#
	# set :cache, Padrino::Cache::Store::Memcache.new(::Memcached.new('127.0.0.1:11211', :exception_retry_limit => 1))
	# set :cache, Padrino::Cache::Store::Memcache.new(::Dalli::Client.new('127.0.0.1:11211', :exception_retry_limit => 1))
	# set :cache, Padrino::Cache::Store::Redis.new(::Redis.new(:host => '127.0.0.1', :port => 6379, :db => 0))
	# set :cache, Padrino::Cache::Store::Memory.new(50)
	# set :cache, Padrino::Cache::Store::File.new(Padrino.root('tmp', app_name.to_s, 'cache')) # default choice
	#

	##
	# Application configuration options
	#
	# set :raise_errors, true       # Raise exceptions (will stop application) (default for test)
	# set :dump_errors, true        # Exception backtraces are written to STDERR (default for production/development)
	# set :show_exceptions, true    # Shows a stack trace in browser (default for development)
	# set :logging, true            # Logging in STDOUT for development and file for production (default only for development)
	# set :public_folder, 'foo/bar' # Location for static assets (default root/public)
	# set :reload, false            # Reload application files (default in development)
	# set :default_builder, 'foo'   # Set a custom form builder (default 'StandardFormBuilder')
	# set :locale_path, 'bar'       # Set path for I18n translations (default your_apps_root_path/locale)
	# disable :sessions             # Disabled sessions by default (enable if needed)
	# disable :flash                # Disables sinatra-flash (enabled by default if Sinatra::Flash is defined)
	# layout  :my_layout            # Layout can be in views/layouts/foo.ext or views/foo.ext (default :application)
	#

	##
	# You can configure for a specified environment like:
	#
	#   configure :development do
	#     set :foo, :bar
	#     disable :asset_stamp # no asset timestamping for dev
	#   end
	#

	##
	# You can manage errors like:
	#
	#   error 404 do
	#     render 'errors/404'
	#   end
	#
	#   error 505 do
	#     render 'errors/505'
	#   end
	#
  end
end
