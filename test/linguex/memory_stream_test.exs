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

    robot_memory = Linguex.MemoryStream.insert!("agent", 0, "robot")
    human_memory = Linguex.MemoryStream.insert!("agent", 1, "human")

    data = Linguex.MemoryStream.alike("agent", "robot girl")
    possibly_robot_memory = data |> Enum.at(0)
    assert possibly_robot_memory.agent == robot_memory.agent
    assert possibly_robot_memory.id == robot_memory.id
  end
end
