module Types
  struct InputWord
    property name
    property value
    def initialize(@name : String, @value : (Nil | String))
    end
  end

  struct Option < InputWord
  end

  struct Argument < InputWord
  end
end

