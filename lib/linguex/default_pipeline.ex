defmodule Linguex.DefaultPipeline do
  @doc "Submit text to the pipeline"
  def submit(content) do
    prompt = Application.fetch_env!(:linguex)[:default_pipeline].submit(content)
    prompt
  end
end
