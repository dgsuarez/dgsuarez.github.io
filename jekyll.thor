require "stringex"
class Jekyll < Thor
  desc "new", "create a new post"
  def new(title, date=nil)
    date ||= Time.now.strftime('%Y-%m-%d')
    filename = "_posts/#{date}-#{title.to_url}.md"

    if File.exist?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: post"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "tags:"
      post.puts " -"
      post.puts "---"
    end
  end

  desc "publish", "publish a draft"
  def publish(draft_path, date=nil)
    date ||= Time.now.strftime('%Y-%m-%d')
    post_path = draft_path.sub(/_drafts\//, "_posts/#{date}-")
    puts post_path
    `git mv #{draft_path} #{post_path}`
  end
end
