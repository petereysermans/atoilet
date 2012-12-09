module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    concat: {
      dist: {
        src: [
          'assets/js/vendor/jquery-1.8.2.min.js',
          'assets/js/vendor/underscore.js',
          'assets/js/vendor/backbone.js',
          'assets/js/vendor/handlebars.runtime.js',
          'assets/js/vendor/modermizr-2.6.2-respond-1.1.0.min.js',
          'assets/js/templates.js'
          'assets/js/templates-helper.js'
          'assets/js/app.js'
        ],
        dest: 'assets/js/main.js',
        separator: ';'
      }
    },

    min: {
      dist: {
        src: ['assets/js/main.js'],
        dest: 'assets/js/main.min.js'
      }
    },

    watch: {
      files: ['assets/js/vendor/*.js', 'assets/js/app.js'],
      tasks: 'concat min'
    }
  });
  
  // Default task.
  grunt.registerTask('default', 'concat min');
};

