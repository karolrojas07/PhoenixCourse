defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller

  alias Discuss.Topic
  alias Discuss.Repo


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
    changeset = Topic.changeset(%Topic{}, topic_params)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

end
