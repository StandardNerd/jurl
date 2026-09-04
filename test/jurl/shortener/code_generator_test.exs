defmodule Jurl.Shortener.CodeGeneratorTest do
  use ExUnit.Case, async: true
  alias Jurl.Shortener.CodeGenerator

  describe "generate/0" do
    test "generates a string of length 3" do
      code = CodeGenerator.generate()
      assert String.length(code) == 3
    end

    test "generates a string containing only lowercase alphanumeric characters" do
      code = CodeGenerator.generate()
      assert code =~ ~r/^[a-z0-9]{3}$/
    end

    test "generates unique strings (highly probable)" do
      code1 = CodeGenerator.generate()
      code2 = CodeGenerator.generate()
      
      # While theoretically possible to collide, it's very unlikely
      # in two subsequent calls if randomness is sound. 
      # 62^3 = 238,328 possibilities.
      assert code1 != code2
    end
  end
end
