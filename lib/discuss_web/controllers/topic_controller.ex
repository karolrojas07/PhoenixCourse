defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Topic
  alias Discuss.Repo

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)

    render(conn, :index, topics: topics)
  end

  @doc """
    Creates a new topic.
    GET /topic/new
  """
  def new(conn, params) do
    changeset = Topic.changeset(%Topic{}, params)

    render(conn, :new, changeset: changeset)
  end

  def create(conn, params) do
    %{"topic" => topic_params} = params
    changeset = conn.assigns.user
      |> Ecto.build_assoc(:topics)
      |> Topic.changeset(topic_params)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: ~p"/topics")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def edit(conn, params) do
    %{"id" => topic_id} = params
    topic = Repo.get!(Topic, topic_id)
    changeset = Topic.changeset(topic)

    render(conn, :edit, topic: topic, changeset: changeset)
  end

  def update(conn, params) do
    %{"id" => topic_id, "topic" => topic_params} = params
    topic = Repo.get!(Topic, topic_id)
    changeset = Topic.changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: ~p"/topics")

      {:error, changeset} ->
        render(conn, :edit, topic: topic, changeset: changeset)
    end
  end

  def delete(conn, params) do
    %{"id" => topic_id} = params
    topic = Repo.get!(Topic, topic_id)

    Repo.delete!(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: ~p"/topics")
  end

  def check_topic_owner(conn,_params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get!(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You are not the owner of this topic")
      |> redirect(to: ~p"/topics")
      |> halt()
    end
  end

end
