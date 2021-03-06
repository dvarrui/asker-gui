# frozen_string_literal: true

require 'rainbow'
require 'rexml/document'
require_relative '../data/map_data'
require_relative 'concept_builder'
require_relative 'code_builder'

module MapBuilder
  def self.build(content)
    begin
      xmlcontent = REXML::Document.new(content)
    rescue REXML::ParseException
      raise "[ERROR] Parsing XML file content"
    end
    lang = read_lang_attribute(xmlcontent)
    context = read_context_attribute(xmlcontent)
    version = read_version_attribute(xmlcontent)

    map_data = MapData.new( lang: lang,
                            context: context,
                            version: version )

    xmlcontent.root.elements.each do |xmldata|
      case xmldata.name
      when 'concept'
        map_data.concepts << ConceptBuilder.build(xmldata: xmldata, parent: map_data)
      when 'code'
        map_data.codes << CodeBuilder.build(xmldata: xmldata, parent: map_data)
      else
        raise("[ERROR] Unkown tag <#{xmldata.name}>")
      end
    end

    map_data
  end

  private_class_method def self.read_lang_attribute(xmldata)
    begin
      lang = xmldata.root.attributes['lang']
    rescue StandardError
      lang = 'en'
    end
    lang
  end

  private_class_method def self.read_context_attribute(xmldata)
    begin
      context = xmldata.root.attributes['context']
    rescue StandardError
      context = 'unknown'
    end
    context
  end

  private_class_method def self.read_version_attribute(xmldata)
    begin
      version = xmldata.root.attributes['version']
    rescue StandardError
      version = '1'
    end
    version
  end
end
