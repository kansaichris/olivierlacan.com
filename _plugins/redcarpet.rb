# https://github.com/nono/Jekyll-plugins/blob/master/redcarpet2_markdown.rb
# Commit SHA: 935197c44413b85be8cf7647c3144a913f2e1560
require 'fileutils'
require 'digest/md5'
require 'redcarpet'
require 'albino'

# already defined in pygments_code.rb
# Jekyll::PYGMENTS_CACHE_DIR = File.expand_path('../../_cache', __FILE__)
FileUtils.mkdir_p(Jekyll::PYGMENTS_CACHE_DIR)

class Redcarpet2Markdown < Redcarpet::Render::HTML
  def block_code(code, lang)
    lang = lang || "text"
    path = File.join(Jekyll::PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest code}.html")
    cache(path) do
      colorized = Albino.colorize(code, lang.downcase)
      add_code_tags(colorized, lang)
    end
  end

  def add_code_tags(code, lang)
    code.sub(/<pre>/, "<pre><code class=\"#{lang}\">").
         sub(/<\/pre>/, "</code></pre>")
  end

  def cache(path)
    if File.exist?(path)
      File.read(path)
    else
      content = yield
      File.open(path, 'w') {|f| f.print(content) }
      content
    end
  end
end

class Jekyll::MarkdownConverter
  def extensions
    Hash[ *@config['redcarpet']['extensions'].map {|e| [e.to_sym, true] }.flatten ]
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet2Markdown.new(extensions), extensions)
  end

  def convert(content)
    return super unless @config['markdown'] == 'redcarpet2'
    markdown.render(content)
  end
end