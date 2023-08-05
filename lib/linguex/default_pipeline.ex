defmodule Linguex.DefaultPipeline do
  @doc "Submit text to the pipeline"
  def submit(content) do
    pipeline = Application.fetch_env!(:linguex, Linguex.Defaults)[:pipeline]
    params = Application.fetch_env!(:linguex, pipeline)
    prompt = pipeline.submit(content, params)

    prompt
    |> Linguex.LLM.complete!()
    |> pipeline.callback()
  end
end
