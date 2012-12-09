watch('(.*).less')  { |md| system("make") }
watch('(.*).coffee')  { |md| system("make") }
watch('tpl/(.*).handlebars')  { |md| system("make") }
