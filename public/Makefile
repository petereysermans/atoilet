#!/usr/bin/make -f

compile:
	handlebars tpl/ -f assets/js/templates.js
	coffee --compile --output assets/js/ app/
	lessc -x assets/css/style.less assets/css/style.css

coffee:
	coffee --compile --watch --output assets/js/ app/

grunt:
	grunt

watch:
	bundle exec watchr make.watchr

build: compile grunt
