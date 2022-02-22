defmodule BubbaWeb.AttemptsController do
  use BubbaWeb, :controller
  alias Main

  def attempts(conn, params) do
    data = Main.verify_answer(params["answer"], params["attempts"])
    json(conn, data)
  end
end
