defmodule DiscussWeb.AuthController do
  use DiscussWeb, :controller
  alias Discuss.User
  alias Discuss.Repo

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{
      email: auth.info.email,
      provider: "github",
      token: auth.credentials.token
    }
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    IO.puts "signout"
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/topics")
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome #{user.email}")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/topics")
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: "/topics")
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        {:ok, user}
    end
  end
end
