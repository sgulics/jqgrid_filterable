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
gem 'jqgrid_filterable', :git =>
'git@github.com:sgulics/jqgrid_filterable.git'
gem 'will_paginate', '~> 3.0.pre4'
```

Usage
-----


Authors
-------
[Steve Gulics](https://github.com/sgulics)
[Steve Whittaker](https://github.com/swhitt)


TODO
----
* Need to implement all of the specs
* Need to remove Oracle specific code

License
-------



