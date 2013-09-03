also_reload 'repoclass.rb' if development?

get '/' do
  erb :form
end

get '/notfound' do
  erb :notfound
end

get '/map' do
  @repo = Repo.new(params[:owner], params[:repo])
  begin
    if params[:submit1]
      @repo.locations
    elsif params[:submit2]
      @repo.country_locations
    end
  rescue
    redirect '/notfound'
  end
  data_table_markers = GoogleVisualr::DataTable.new
  data_table_markers.new_column('string' , 'Location' )
  data_table_markers.new_column('number' , 'Contributions')
  data_table_markers.add_rows(@repo.location_count.size)

  i = 0
  @repo.location_count.each do |location, count|
    unless location == "Location Unknown"
      data_table_markers.set_cell(i,0,location)
      data_table_markers.set_cell(i,1, count)
      i += 1
    end
  end
  if params[:submit1]
    opts = { :displayMode => 'markers', :region => 'world', :legend => 'none',
             :colors => ['FF8F86', 'C43512']}
  elsif params[:submit2]
    opts = { :displayMode => 'region', :region => 'world', :legend => 'none',
             :colors => ['FF8F86', 'C43512']}
  end
  @chart_markers = GoogleVisualr::Interactive::GeoChart.new(data_table_markers, opts)

  erb :map

end













