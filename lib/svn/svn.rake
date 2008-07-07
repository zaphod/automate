namespace :svn do
  desc 'rake for svn st'
  task :st do
    puts %x[svn st]
  end
  
  desc 'check for svn conflicts and fail if one is found'
  task :fail_on_conflict do
    puts "checking for conflicts"
    system "svn st | grep '^C '"
    raise "svn conflicts detected" if $?.success?
  end
  
  desc 'rake for svn up'
  task :up do
    puts %x[svn up]
  end

  desc 'rake for svn add'
  task :add do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('?').lstrip
      if line[0,1] =~ /\?/
        %x[svn add #{trimmed_line}]
        puts %[added #{trimmed_line}]
      end
    end
  end
  
  desc 'rake for svn delete'
  task :delete do
    %x[svn st].split(/\n/).each do |line|
      trimmed_line = line.delete('!').lstrip
      if line[0,1] =~ /\!/
        %x[svn rm #{trimmed_line}]
        puts %[removed #{trimmed_line}]
      end
    end
  end
  
  desc 'strip svn folders'
  task :strip do
    Find.find(File.expand_path('.')) { |path| %x[rm -rf #{path}] if path =~ /\.svn$/ }
  end
  
  RELEASE_1_BRANCHNAME = "release_1.0"
  
  desc 'Tag a revision of trunk'
  task :tag do
    require RAILS_ROOT + "/lib/svn"
    revision = Readline.readline("revision: ").strip
    tag_name = Readline.readline("tag name: ").strip
    svn = SVN.new
    command = "svn cp -r #{revision} #{svn.branch_url(RELEASE_1_BRANCHNAME)} #{svn.tag_url(tag_name)}"
    puts command
    system command
  end
  
  desc 'Merge revisions of a branch to trunk'
  task :merge do
    require RAILS_ROOT + "/lib/svn"
    branch_name = Readline.readline("branch (#{RELEASE_1_BRANCHNAME}): ").strip
    branch_name = RELEASE_1_BRANCHNAME if branch_name.blank?
    
    start_revision = Readline.readline("start revision: ").strip
    raise "You must specify a start revision" if start_revision.blank?
    
    end_revision = Readline.readline("end revision (#{start_revision.next}): ").strip
    end_revision = start_revision.next if end_revision.blank?
    
    svn = SVN.new
    command = "svn merge -r#{start_revision}:#{end_revision} #{svn.branch_url(branch_name)}"
    puts command
    system command
  end
end