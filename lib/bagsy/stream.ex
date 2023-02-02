defmodule Bagsy.Stream do
  alias Bagsy.Conn
  alias Exqlite.Sqlite3, as: Sqlite

  def new(%Conn{} = conn) do
    Stream.resource(
      fn ->
        {:ok, statement} = Sqlite.prepare(conn.db, "SELECT * FROM messages")

        statement
      end,
      fn
        {:done, statement} ->
          {:halt, statement}

        statement ->
          case Sqlite.multi_step(conn.db, statement) do
            :busy -> {[], statement}
            {:rows, rows} -> {rows, statement}
            {:done, rows} -> {rows, {:done, statement}}
            {:error, _reason} -> {:halt, statement}
          end
      end,
      fn statement ->
        :ok = Exqlite.Sqlite3.release(conn.db, statement)
      end
    )
  end
end
