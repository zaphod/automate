task :selenium_full_build do
	remote_box = "IPADDRESS"

	puts "Telling remote box to update code/database and start server"
	system "c:/putty #{remote_box} -l login -pw password -m c:/deploy"

	begin
		puts "Running the full selenium suite (using the local browser against the remote server)"
		Rake::Task[:'qa:acc'].invoke
	rescue
		raise
	ensure
		FileUtils.cp_r "all_spec_results.html", ENV['CC_BUILD_ARTIFACTS']
	end
end