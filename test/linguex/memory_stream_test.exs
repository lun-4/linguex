defmodule LinguexWeb.MemoryStreamTest do
  use Linguex.DataCase, async: false
  alias Linguex.Test.DataGenerator

  import Mox
  setup :verify_on_exit!

  @robot_embedding DataGenerator.an_embedding()
  @robot_girl_embedding DataGenerator.an_embedding_from(@robot_embedding)
  @human_embedding DataGenerator.an_embedding()

  test "it works somehow" do
    stub(Linguex.LLMBehaviourMock, :embed!, fn args ->
      case args do
        "robot" -> @robot_embedding
        "human" -> @human_embedding
        "robot girl" -> @robot_girl_embedding
      end
    end)

    {:ok, {memory, vector}} = Linguex.MemoryStream.insert!("agent", 0, "robot")
    {:ok, {memory, vector}} = Linguex.MemoryStream.insert!("agent", 1, "human")
    {:ok, {memory, vector}} = Linguex.MemoryStream.insert!("agent", 2, "robot girl")

    data = Linguex.MemoryStream.alike("agent", "robot girl")
  end
end
