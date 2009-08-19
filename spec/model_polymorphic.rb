
require 'spec_env'
include Lore::Spec_Fixtures::Polymorphic_Models

describe(Lore::Table_Accessor) do
  before do
    # flush_test_data()
  end

  it "implements the Liskov substitution principle" do
  end

  it "implements inverse polymorphism" do
    
    Asset.__associations__.concrete_models.length.should == 2
    
    expected = { 'public.asset' => :model }
    Media_Asset.__associations__.polymorphics.should_be expected
    
    5.times { 
      info = Media_Asset_Info.create(:description => 'a media file')
      media = Media_Asset.create(:folder     => '/tmp/spec/media/', 
                                 :filename   => 'music.ogg', 
                                 :info_id    => info.pkey, 
                                 :media_type => 'sound')
      info = Document_Asset_Info.create(:relevance => 5)
      docum = Document_Asset.create(:folder   => '/tmp/spec/docs/', 
                                    :filename => 'sample.txt', 
                                    :info_id    => info.pkey, 
                                    :doctype  => 'plaintext')
      
    }

    Asset.find(10).sort_by(Asset.asset_id, :desc).entities.each { |a|
      puts a.class.to_s
    }

    info = Media_Asset_Info.create(:description => 'a media file')
    media = Media_Asset.create(:folder     => '/tmp/spec/media/', 
                               :filename   => 'music.ogg', 
                               :info_id    => info.pkey, 
                               :media_type => 'sound')
    info = Document_Asset_Info.create(:relevance => 5)
    docum = Document_Asset.create(:folder   => '/tmp/spec/docs/', 
                                  :filename => 'sample.txt', 
                                  :info_id    => info.pkey, 
                                  :doctype  => 'plaintext')

    media_polymorphic_id = media.asset_id
    docum_polymorphic_id = docum.asset_id

    asset = Asset.select { |a|
      a.where(Asset.asset_id.is media_polymorphic_id)
      a.limit(1)
    }.first
    asset.is_a?(Media_Asset).should == true
    asset.is_a?(Asset).should == true
    asset.media_type.should == 'sound'
    
    asset = Asset.select_polymorphic { |a|
      a.where(:asset_id.is docum_polymorphic_id)
      a.limit(1)
    }.first
    asset.is_a?(Document_Asset).should == true
    asset.is_a?(Asset).should == true
    asset.doctype.should == 'plaintext'
  end

end
