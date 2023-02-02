defmodule Bagsy.Conn do
  defstruct [:db, :file]

  alias Exqlite.Sqlite3, as: Sqlite

  def new(file) when is_binary(file) do
    {:ok, db} = Sqlite.open(file, mode: :readonly)

    %__MODULE__{
      db: db,
      file: file
    }
  end
end
