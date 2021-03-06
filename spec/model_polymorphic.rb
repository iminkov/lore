
require 'spec_env'
include Lore::Spec_Fixtures::Polymorphic_Models

describe(Lore::Table_Accessor) do
  before do
    flush_test_data()
  end

  it "implements the Liskov substitution principle" do
  end

  it "implements inverse polymorphism" do
    
    Asset.is_polymorphic?.should == true
    Media_Asset.is_polymorphic?.should == false
    Document_Asset.is_polymorphic?.should == false
    
    expected = { 'public.asset' => :model }
    Media_Asset.__associations__.polymorphics.should_be expected

    Asset.__associations__.concrete_models.length.should == 2

    5.times { 
      info = Media_Asset_Info.create(:description => 'a media file')
      media = Media_Asset.create(:folder     => '/tmp/spec/media/', 
                                 :filename   => 'music.ogg', 
                                 :hits       => 123, 
                                 :info_id    => info.pkey, 
                                 :media_type => 'sound')
      info = Document_Asset_Info.create(:relevance => 5)
      docum = Document_Asset.create(:folder   => '/tmp/spec/docs/', 
                                    :filename => 'sample.txt', 
                                    :info_id  => info.pkey, 
                                    :position => 23, 
                                    :doctype  => 'plaintext')
      
    }
    polymorphics = Asset.find(10).polymorphic.sort_by(Asset.asset_id, :desc).entities
    polymorphics.length.should == 10
    polymorphics.each_with_index { |a,idx|
      expected = (idx % 2 == 1)? true : false
      a.is_a?(Media_Asset).should == expected
      a.is_a?(Document_Asset).should == !expected
    }
  end

  it "Handles inherited fields like in regular selects" do

    info = Media_Asset_Info.create(:description => 'a media file')
    media = Media_Asset.create(:folder     => '/tmp/spec/media/', 
                               :filename   => 'music.ogg', 
                               :hits       => 123, 
                               :info_id    => info.pkey, 
                               :media_type => 'sound')
    info = Document_Asset_Info.create(:relevance => 5)
    docum = Document_Asset.create(:folder   => '/tmp/spec/docs/', 
                                  :filename => 'sample.txt', 
                                  :info_id  => info.pkey, 
                                  :position => 42, 
                                  :doctype  => 'plaintext')

    media_polymorphic_id = media.asset_id
    docum_polymorphic_id = docum.asset_id

    # Select an Asset which is known to be a concrete 
    # Media_Asset: 
    asset = Asset.polymorphic_select { |a|
      a.where(Asset.asset_id.is media_polymorphic_id)
      a.limit(1)
    }.first
    asset.is_a?(Media_Asset).should == true
    asset.is_a?(Asset).should == true
    asset.media_type.should == 'sound'
    
    # Select an Asset which is known to be a concrete 
    # Document_Asset: 
    asset = Asset.polymorphic_select { |a|
      a.where(Asset.asset_id.is docum_polymorphic_id)
      a.limit(1)
    }.first
    asset.is_a?(Document_Asset).should == true
    asset.is_a?(Asset).should == true
    asset.doctype.should == 'plaintext'
  end

  it "allows lazy polymorphic selects" do
    concrete_instances = []
    abstract_docum_ids = []
    abstract_media_ids = []
    5.times { 
      info = Media_Asset_Info.create(:description => 'a media file')
      media = Media_Asset.create(:folder     => '/tmp/spec/media/', 
                                 :filename   => 'music.ogg', 
                                 :hits       => 123, 
                                 :info_id    => info.pkey, 
                                 :media_type => 'sound')
      info = Document_Asset_Info.create(:relevance => 5)
      docum = Document_Asset.create(:folder   => '/tmp/spec/docs/', 
                                    :filename => 'sample.txt', 
                                    :info_id  => info.pkey, 
                                    :position => 12, 
                                    :doctype  => 'plaintext')
      concrete_instances << media
      concrete_instances << docum
      abstract_docum_ids << docum.asset_id
      abstract_media_ids << media.asset_id
    }
    abstract_ids = concrete_instances.map { |c| c.asset_id }

    abstract_instances = Asset.select { |a|
      a.where(a.asset_id.in(abstract_ids))
      a.order_by(:asset_id, :desc)
    }.each { |a|
      a.class.should == Asset
      a.concrete_instance.class.should == Document_Asset if abstract_docum_ids.include?(a.asset_id)
      a.concrete_instance.class.should == Media_Asset if abstract_media_ids.include?(a.asset_id)
    }

  end

end
