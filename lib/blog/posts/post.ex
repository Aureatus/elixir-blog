defmodule Blog.Posts.Post do
  alias Blog.Comments.Comment
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :utc_datetime
    field :visible, :boolean, default: true

    has_many :comments, Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visible])
    |> validate_required([:title, :content, :published_on, :visible])
    |> unique_constraint(:title)
  end
end
