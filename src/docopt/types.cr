module Types

  ########## InputWord types ##########

  struct InputWordStruct
    property name
    property value
    def initialize(@name : String, @value : (Nil | String))
    end
  end

  struct Option < InputWordStruct end
  struct Argument < InputWordStruct end

  alias InputWord = Option | Argument

  ########## InputSection types ##########

  struct InputSectionStruct
    property value
    def initialize(@value : (String))
    end
  end

  struct OptionSection < InputSectionStruct end
  struct UsageSection < InputSectionStruct end
end

