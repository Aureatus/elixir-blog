defmodule Blog.Comments.Comment do
  alias Blog.Posts.Post
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string

    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :post_id])
    |> validate_required([:content, :post_id])
    |> foreign_key_constraint(:post_id)
  end
end
