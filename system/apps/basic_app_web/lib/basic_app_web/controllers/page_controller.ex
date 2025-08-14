defmodule BasicAppWeb.PageController do
  use BasicAppWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end

  def health(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "ok", service: "basic_app"})
  end
end
