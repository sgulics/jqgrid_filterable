require "jqgrid_filterable/version"

# JsgridFilterable allows the use of the jsGrid plugin's sorting and searching functionality easily with an
# ActiveRecord model. Depends on Mislav's will_paginate gem.
#
# Author:: Steve Gulics and Steve Whittaker
#
# JsgridFilterable should be set-up in the model using the +jqgrid_filterable+ method:
#
#   class Person < ActiveRecord::Base
#     jqgrid_filterable :include => [:address, :account], :columns => {:address => 'address.description'}
#   end
#
#   Person.paginate_by_filter(params)
#
#
# See the +jqgrid_filterable+ documentation for more details.
module JqgridFilterable

  class << self
    def included(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods

    # +jqgrid_filterable+ sets the model up for use with this plugin. There are a number of options you can
    # set to change the behavior of the plugin:
    # * +columns+: Often times, the dataIndex used in an column model does not map 1:1 to a column name,
    #   or it may be in an entirely different table. This hash allows the mapping from dataIndex to sql selector.
    # * +per_page+: Sets the default per_page used by will_paginate and the plugin. If will_paginate is already set
    #   to use a certain number, uses that. If nothing is specified, defaults to 100.
    # * +include+: An array that contains the associations to load.
    # * +special_filters+: A hash that allows custom handling to be used in the filter block. Keys are the dataIndex,
    #   values are either a Proc object or a Symbol that points to a class method. The parameters passed to the proc
    #   or method are the conditions array, the values array, the type of filter, and the value of the filter.
    def jqgrid_filterable(merge_opts=nil)
      # old_per_page = class_variable_get(:@@per_page) rescue nil
      # opts = { :per_page => (old_per_page || 100), :columns => {}, :include => [], :special_filters => {}}

      if merge_opts
        raise ArgumentError, 'parameter hash expected' unless merge_opts.respond_to? :symbolize_keys
        jqgrid_filterable_options.merge!(merge_opts.symbolize_keys)
      end

      # class_variable_set(:@@per_page, opts[:per_page])

      # write_inheritable_attribute(:jqgrid_filterable_options, opts)

    end

    # +jqgrid_filter_and_sort_options+ will return the hash of the options that are meant to be sent to will_paginate when
    # using the +jqgrid_paginate_by_filter+ method. It also accepts an options hash that can override or add any of the options
    # that are set in the +jqgrid_filterable+ method
    def jqgrid_filter_and_sort_options(params={}, options={})
      raise ArgumentError, 'parameter hash expected' unless params.respond_to? :symbolize_keys
      params.symbolize_keys! if params.respond_to? :symbolize_keys!
      options = jqgrid_filterable_options.merge(options)
      

      limit, page = jqgrid_calculate_limit_and_page(params, options)
      sort = jqgrid_determine_sort(params, options)
      conditions, values = jqgrid_get_conditions_and_values(params, options)

      {:page => page, :per_page => limit, :order=>sort, :include => options[:include],
              :conditions => [conditions.join(" and ")].concat(values)}

    end

    # +jqgrid_paginate_by_filter+ is the main method used in controllers. Uses the options and parameters
    # passed in, processes them and then passes them to will_paginate.
    def jqgrid_paginate_by_filter(params={}, options={})
      paginate(jqgrid_filter_and_sort_options(params, options))
    end

    # for will_paginate's default +per_page+
    def jqgrid_per_page
      # @@per_page rescue nil
      jqgrid_filterable_options[:per_page]
    end

    # Returns the options stored by the plugin.
    def jqgrid_filterable_options
      if read_inheritable_attribute(:jqgrid_filterable_options).nil?
        old_per_page = class_variable_get(:@@per_page) rescue 30
        opts = { :per_page => old_per_page, :columns => {}, :include => [], :special_filters => {}}
        write_inheritable_attribute(:jqgrid_filterable_options, opts )
      end
      read_inheritable_attribute(:jqgrid_filterable_options) 
    end

    def jqgrid_calculate_limit_and_page(params, options)
      limit = params[:rows].try(:to_i) || class_variable_get(:@@per_page) rescue 100
      page =  params[:page].try(:to_i) || 1
      [limit, page]

    end

    def jqgrid_determine_sort(params, options)
      return (options[:default_sort] || 'created_at') if params[:sidx].blank?

      if options[:columns][params[:sidx].to_sym]
        "#{options[:columns][params[:sidx].to_sym]} #{params[:sord]}"
      else
        "#{params[:sidx]} #{params[:sord]}"
      end

    end

    def jqgrid_get_conditions_and_values(params, options)
      conditions = options[:conditions] || []
      values = options[:values] || []
      if params[:_search] == "true"
        # Simple Search
        if !params[:searchField].blank? and !params[:searchOper].blank?
          jqgrid_process_condition(params[:searchField], params[:searchString], conditions, values, options)
        # Toolbar Search
        elsif !params[:filters].blank?
          filters = ActiveSupport::JSON.decode(params[:filters])
          rules = filters["rules"]
          rules.each do |rule|
            field = rule["field"]
            op = rule["op"] # ignore for now
            value = rule["data"]
            jqgrid_process_condition(field, value, conditions, values, options)
          end
        end
      elsif options[:default_filter]
        options[:default_filter] = [options[:default_filter]] if options[:default_filter].is_a? Hash
        options[:default_filter].each do |f|
          jqgrid_process_condition(f[:field], f[:value], conditions, values, options)
        end
      end
      [conditions, values]
      
    end


    def jqgrid_process_condition(field, value, conditions, values, options)
      custom_handler = options[:special_filters][field.to_sym]

      if custom_handler
        if custom_handler.kind_of? Proc
          custom_handler.call(conditions, values, value)
        elsif (custom_handler.kind_of?(String) || custom_handler.kind_of?(Symbol))
          send(custom_handler, conditions, values, value)
        else
          raise ArgumentError, "custom handler for #{field} not Proc or Symbol"
        end
      else
        field = options[:columns][field.to_sym] if options[:columns][field.to_sym]
        # TODO The data stuff is Oracle specific. We may want to move it out
        # TODO Support the jqGrid's search options, i,e, sopt.
        # jqGrid supports ['eq','ne','lt','le','gt','ge','bw','bn','in','ni','ew','en','cn','nc'] 
        if self.columns_hash[field].try(:type) == :datetime
          date = DateTime.parse(value) rescue nil
          if date
            conditions << "trunc(#{ActiveRecord::Base.connection.quote_column_name(field)}) = ?"
            values << value
          end
        else
          conditions << "UPPER(#{ActiveRecord::Base.connection.quote_column_name(field)}) like ?"
          values << "%#{value.upcase}%"
        end
      end

    end

    def jqgrid_datetime_proc(column_name)
      Proc.new do |conditions, values, value|
        date = nil
        if value.is_a? Date
          date = value
        elsif !value.blank?
          date = DateTime.parse(value) rescue nil
        end
        conditions << "trunc(#{ActiveRecord::Base.connection.quote_column_name(column_name.to_s)}) = ?"
        values << date
      end

    end

    def jqgrid_est_datetime_filter(column_name)
      Proc.new do |conditions, values, value |
        zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
        date = zone.parse(value.to_s)
        conditions << "#{column_name.to_s} >= ? and #{column_name.to_s} <= ?"
        values << date.utc.to_datetime
        values << date.end_of_day.utc.to_datetime
      end
    end


  end
  
  
end
