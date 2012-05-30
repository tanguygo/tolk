module Tolk
  module Import
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods

      def import_secondary_locales
        (I18n.available_locales - [Tolk::Locale.primary_locale.name.to_sym]).each {|l| import_locale(l) }
      end

      def import_locale(locale_name)
        locale  = Tolk::Locale.find_or_create_by_name(locale_name)
        data    = locale.read_locale_file(locale_name)
        phrases = Tolk::Phrase.all
        count   = 0

        data.each do |key, value|
          phrase = phrases.detect {|p| p.key == key}

          if phrase
            translation = locale.translations.new(:text => value, :phrase => phrase)
            count = count + 1 if translation.save
          else
            puts "[ERROR] Key '#{key}' was found in #{locale_name}.yml but #{Tolk::Locale.primary_language_name} translation is missing"
          end
        end

        puts "[INFO] Imported #{count} keys from #{locale_name}.yml"
      end

    end

    def read_locale_file(locale_name)
      self.class.flat_hash(I18n.backend.send(:translations)[locale_name] || {})
    end

  end
end
