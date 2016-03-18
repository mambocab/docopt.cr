module Types
  struct InputWordStruct
    property name
    property value
    def initialize(@name : String, @value : (Nil | String))
    end
  end

  struct Option < InputWordStruct
  end

  struct Argument < InputWordStruct
  end

  alias InputWord = Option | Argument
end

