defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.CommentsFixtures

  @create_attrs %{
    title: "some title",
    content: "some content",
    visible: true,
    published_on: DateTime.utc_now()
  }
  @update_attrs %{
    title: "some updated title",
    subtitle: "some updated subtitle",
    content: "some updated content"
  }
  @invalid_attrs %{title: nil, subtitle: nil, content: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end

    test "search returns correct result", %{conn: conn} do
      post = post_fixture()
      conn = get(conn, ~p"/posts", %{search_query: post.title})
      assert html_response(conn, 200) =~ post.content

      conn = get(conn, ~p"/posts", %{search_query: String.slice(post.title, 1..3)})
      assert html_response(conn, 200) =~ post.content

      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ post.content

      conn = get(conn, ~p"/posts", %{search_query: "incorrect query"})
      refute html_response(conn, 200) =~ post.content
    end
  end

  describe "show" do
    test "displays post", %{conn: conn} do
      post = post_fixture()
      conn = get(conn, ~p"/posts/#{post.id}")
      assert html_response(conn, 200) =~ "Post #{post.id}"
    end

    test "displays comments on post", %{conn: conn} do
      post = post_fixture()
      comment = comment_fixture(post_id: post.id)

      conn = get(conn, ~p"/posts/#{post.id}")
      assert html_response(conn, 200) =~ comment.content
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create comment" do
    test "redirects to show when data is valid", %{conn: conn} do
      post = post_fixture(@create_attrs)
      comment = %{post_id: post.id, content: "Testing comment"}
      conn = post(conn, ~p"/comments", comment: comment)

      conn = get(conn, ~p"/posts/#{post.id}")
      assert html_response(conn, 200) =~ comment.content
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Oops, something went wrong!"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post} do
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end
