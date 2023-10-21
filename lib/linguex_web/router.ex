defmodule LinguexWeb.Router do
  use Phoenix.Router, helpers: false

  # Import common connection and controller functions to use in pipelines
  import Plug.Conn
  import Phoenix.Controller

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", LinguexWeb do
    pipe_through(:api)
  end

  scope "/api/v0/agent", LinguexWeb do
    get("/call", AgentController, :input)
    get("/list", AgentController, :list)
  end
end
