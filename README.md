jqgrid_filterable
=================

jgrid_filterable allow the use of the [jqgrid](http://www.trirand.com/blog/) jquery plugin's
sorting and searching functionality easily with an ActiveRecord model

This gem is based on Steve Whittaker's [extjs_filterable](https://github.com/swhitt/extjs_filterable)


Installation
------------
Add the following lines to your application's Gemfile to install this
and the will_paginate gem. Currently, jqgrid_filterabble only support pagination
with will_paginate, but I will add support for other paging gems once I
finish writing all of the specs

```ruby
gem 'jqgrid_filterable', :git => 'git@github.com:sgulics/jqgrid_filterable.git'
gem 'will_paginate', '~> 3.0.pre4'
```

Usage
-----
The first step is to include the jqgrid_filterable module in your
ActiveRecord model

```ruby
class User < ActiveRecord::Base

  include jqgrid_filterable

end
```

jgrid_filterable takes a number of options

* `columns`:  Often times, the dataIndex used in an column model does not map 1:1 to a column name, or it may be in an entirely different table. This hash allows the mapping from dataIndex to sql selector.
* `per_page`:  Sets the default per_page used by will_paginate and the plugin. If will_paginate is already set to use a certain number, uses that. If nothing is specified, defaults to 30.
* `include`:  An array that contains the associations to load.
* `special_filters`:  A hash that allows custom handling to be used in the filter block. Keys are the dataIndex, values are either a Proc object or a Symbol that points to a class method. The parameters passed to the proc or method are the conditions array, the values array, the type of filter, and the value of the filter.
* `default_sort`: The default column to sort by if no sorting parameter is passed in. Defaults to created_at

Here is a more complext configuration:

```ruby
class MyClass < ActiveRecord::Base
  
  include jqgrid_filterable

  jqgrid_filterable({
    :default_sort=> "alerted_at desc",
    :special_filters=> {
      :alerted_at=> filter_alerted_at,
      :contacts=> Proc.new do |conditions, values, value |
          conditions << "(UPPER(contact1) like ? or UPPER(contact2) like ?)"
          values << "%#{value.upcase}%" << "%#{value.upcase}%"
        end
      }
    })

  def filter_alerted_at(conditions, values, value)
    #perform custom logic
    #
  end
end  
```
If the above example we are defining the following:

* The `default_sort` will be alerted_at desc
* When the alerted_at field is being filtered use the custom
  filter_alerted_at method to provide the logic. The method is passed in
  the current conditions and values array along with the value being
  filtered.
* When contacts is being filtered use the block. In this silly example,
  the table has 2 columns: contact1 and contact2. We will filter both of
  these columns by the value being passed in. The Grid only has a column
  called Contracts which is mapped a transient fields called `contracts`

In your controller code you would pass in the params as follows:

```ruby
  def index
    ...
    User.jqgrid_paginate_by_filter(params)
    ...
  end
```







Authors
-------
[Steve Gulics](https://github.com/sgulics)

[Steve Whittaker](https://github.com/swhitt)


TODO
----
* Need to implement all of the specs
* Need to remove Oracle specific code
* Need to support all of jqgrid's search options


License
-------



