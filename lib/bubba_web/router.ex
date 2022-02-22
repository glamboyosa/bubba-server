defmodule BubbaWeb.Router do
  use BubbaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BubbaWeb do
    pipe_through :api

    post("/attempts", AttemptsController, :attempts)
  end

  scope "/", BubbaWeb do
    pipe_through :browser

    get "/", PageController, :index
  end
end
