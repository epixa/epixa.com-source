module Jekyll

  class CategoryIndex < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_index.html')

      self.data['category'] = category
      self.data['title'] = self.data['title'] + " - " + category
    end
  end

  class CategoryFeed < Page
    def initialize(site, base, dir, category)
      @site = site
      @base = base
      @dir  = dir
      @name = 'atom.xml'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'category_feed.xml')

      self.data['category'] = category
      self.data['title'] = category
    end
  end

  class CategoryGenerator < Generator
    safe true

    def generate(site)
      if (site.layouts.key? 'category_index') && (site.layouts.key? 'category_feed')
        dir = site.config['category_index_dir'] || 'category'
        site.categories.keys.each do |category|
          category_dir = File.join(dir, category)
          write_category_index(site, category_dir, category)
          write_category_feed(site, category_dir, category)
        end
      end
    end

    def write_category_index(site, dir, category)
      index = CategoryIndex.new(site, site.source, dir, category)
      index.render(site.layouts, site.site_payload)
      index.write(site.dest)
      site.pages << index
    end

    def write_category_feed(site, dir, category)
      feed = CategoryFeed.new(site, site.source, dir, category)
      feed.render(site.layouts, site.site_payload)
      feed.write(site.dest)
      site.pages << feed
    end
  end

end