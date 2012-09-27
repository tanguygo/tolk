module Tolk
  class Phrase < ActiveRecord::Base
    self.table_name = "tolk_phrases"

    attr_accessible :key

    validates_uniqueness_of :key

    paginates_per 30

    has_many :translations, :class_name => 'Tolk::Translation', :dependent => :destroy do
      def primary
        to_a.detect {|t| t.locale_id == Tolk::Locale.primary_locale.id}
      end

      def for(locale)
        to_a.detect {|t| t.locale_id == locale.id}
      end
    end

    attr_accessor :translation

    def self.containing_text(query)
      self.where(Tolk::Phrase.arel_table[:key].matches("%#{query}%"))
    end
  end
end
