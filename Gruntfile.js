module.exports = function(grunt) {

	//////////////////
	// config vars  //
	//////////////////
	// files: ['!node_modules/**/*.js', '**/*.js', '**/*.html']
	// filesLib = ['index.js', 'lib/**/*.js'],
	var docsTmplDir = 'docs-tmpl',
		filesDocsTmpl = docsTmplDir + '/**/*.tmpl',
		filesLib = ['lib/**/*.js'],
		filesCSS = ['css/**/*.css'],
		filesTmpl = ['tmpl/**/*.tmpl'],
		filesWatch = filesTmpl.concat(filesLib, filesCSS, filesDocsTmpl, ['Gruntfile.js']),
		tasksBuild = ['readme'],
		tasksWatch = ['component-build', 'jshint'],
		processReadmeHeaderSrc          = docsTmplDir + '/README_header.md.tmpl',
		processReadmeHeaderDestination  = docsTmplDir + '/README_header.md',
		processLicenseSrc               = docsTmplDir + '/LICENSE.tmpl',
		processLicenseDestination       = 'LICENSE',
		npmConfig 						= grunt.file.readJSON('package.json'),
		filesPreProcess 				= {};
// console.log('filesWatch', filesWatch);
	npmConfig.year = grunt.template.today('yyyy');
	filesPreProcess[docsTmplDir + '/README_header.md'] = docsTmplDir + '/README_header.md.tmpl';
	filesPreProcess[docsTmplDir + '/LICENSE.tmpl'] = 'LICENSE';

	/////////////////////////////
	// Project configuration.  //
	/////////////////////////////
	grunt.initConfig({
		pkg: grunt.file.readJSON('package.json'),
		preprocess: {
			options: {
				context: {
					year: grunt.template.today('yyyy')
				}
			},
			readme: {
				options: {
					context: npmConfig
				},
				files: filesPreProcess
			}
		},
		concat: {
			options: {
				separator: ''
			},
			//  // '2013'
			dist: {
				src: [docsTmplDir + '/README_header.md', docsTmplDir + '/README_footer.md', 'LICENSE'],
				dest: 'README.md'
			}
		},
		jshint: {
			all: {
				files: {
					src: filesLib
				},
				options: {
					jshintrc: '.jshintrc'
				}
			}
		},
		clean: [docsTmplDir + "/**/*.md"],
		watch: {
			options: {
				livereload: 35730
			},
			files: filesWatch,
			tasks: tasksWatch
			// tasks: tasksBuild
		}
	});

	/*--------------------------------------
	Readme custom task
	---------------------------------------*/
	grunt.registerTask("readme-concat", ["preprocess:readme", "concat", "clean"]);
	// keep in here for the watch task
	grunt.registerTask('readme', 'Concatenate readme docs', function() {
		var done = this.async();
		var exec = require('child_process').exec;
		exec('make readme', function(error, stdout, stderr) {
			done();
		});
	});

	grunt.registerTask('component-build', 'Build component', function() {
		var done = this.async();
		var exec = require('child_process').exec;
		exec('make public-quick', function(error, stdout, stderr) {
			done();
		});
	});


	///////////////////////////
	// Loading dependencies  //
	///////////////////////////
	for (var key in grunt.file.readJSON("package.json").devDependencies) {
		if (key !== "grunt" && key.indexOf("grunt") === 0) grunt.loadNpmTasks(key);
	}

	// register tasks
	grunt.registerTask("template", ["preprocess:readme"]);
	grunt.registerTask("build", tasksBuild);
	grunt.registerTask("default", ["watch"]);
};