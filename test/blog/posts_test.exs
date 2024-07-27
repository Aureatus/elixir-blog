defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures

    @invalid_attrs %{title: nil, subtitle: nil, content: nil}

    test "list_posts/0 with no filter" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "list_posts/0 respects visible field" do
      post1 = post_fixture(title: "title1", visible: true)
      _post2 = post_fixture(title: "title2", visible: false)
      assert Posts.list_posts() == [post1]
    end

    test "list_posts/0 respects publish date based visibility" do
      _post =
        post_fixture(
          title: "title1",
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(1, :day)
        )

      assert Posts.list_posts() == []
    end

    test "list_posts/0 respects publish date ordering" do
      post1 =
        post_fixture(
          title: "title1",
          published_on: DateTime.utc_now() |> DateTime.add(-3, :day)
        )

      post2 =
        post_fixture(
          title: "title2",
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(-2, :day)
        )

      post3 =
        post_fixture(
          title: "title3",
          visible: true,
          published_on: DateTime.utc_now() |> DateTime.add(-1, :day)
        )

      assert Posts.list_posts() == [post3, post2, post1]
    end

    test "list_posts/1 filters post by input" do
      post = post_fixture()
      assert Posts.list_posts("") == [post]
      assert Posts.list_posts(post.title) == [post]
      assert Posts.list_posts(String.slice(post.title, 0..2)) == [post]
      assert Posts.list_posts(String.upcase(post.title)) == [post]

      assert Posts.list_posts("incorrect") == []
    end

    test "list_posts/1 with incorrect search returns no posts" do
      _post = post_fixture()
      assert Posts.list_posts("incorrect") == []
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      time = DateTime.utc_now()

      valid_attrs = %{
        title: "some title",
        content: "some content",
        visible: false,
        published_on: time
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.title == "some title"
      assert post.content == "some content"
      assert post.visible == false
      assert DateTime.compare(time, valid_attrs.published_on) == :eq
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        title: "some updated title",
        content: "some updated content",
        visible: false
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.title == "some updated title"
      assert post.content == "some updated content"
      assert post.visible == false
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
