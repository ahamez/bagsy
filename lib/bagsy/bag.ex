defmodule Bagsy.Bag do
  defstruct [:file, :start_time, :end_time, :duration, :topics, :counters, :gnss]

  alias Bagsy.{Conn, Parser, Stream, Topic}
  alias Exqlite.Sqlite3, as: Sqlite

  defmodule Accumulator do
    defmodule Gnss do
      defstruct min_latitude: 90,
                max_latitude: -90,
                min_longitude: 180,
                max_longitude: -180
    end

    defstruct counters: %{}, gnss: %{}
  end

  def new(%Conn{} = conn) do
    {:ok, topics} = topics(conn)

    {_parser, acc} =
      Enum.reduce(
        Stream.new(conn),
        {Parser.new(topics), init_accumulator(topics)},
        &parse_message/2
      )

    {:ok, start_time} = start_time(conn)
    {:ok, end_time} = end_time(conn)

    %__MODULE__{
      file: Path.basename(conn.file),
      topics: topics,
      start_time: start_time,
      end_time: end_time,
      duration: DateTime.diff(end_time, start_time, :millisecond),
      counters: acc.counters,
      gnss: acc.gnss
    }
  end

  # -- Private

  defp init_accumulator(topics) do
    %Accumulator{}
    |> init_gnss_accumulator(topics)
  end

  defp init_gnss_accumulator(acc, topics) do
    gnss =
      for %Topic{id: id, type: "gps_msgs/msg/GPSFix"} <- topics, into: %{} do
        {id, %Accumulator.Gnss{}}
      end

    %Accumulator{acc | gnss: gnss}
  end

  defp parse_message(msg, {parser, acc}) do
    [_id, topic_id, _timestamp, data] = msg

    acc = update_counters(acc, topic_id)

    acc =
      case Parser.parse_message(parser, topic_id, data) do
        {:ok, msg} -> handle_message(acc, topic_id, msg)
        :unknown_message_type -> acc
      end

    {
      parser,
      acc
    }
  end

  defp topics(conn) do
    with {:ok, statement} <- Sqlite.prepare(conn.db, "SELECT id, name, type FROM topics"),
         {:ok, flat_topics} <- Sqlite.fetch_all(conn.db, statement),
         :ok <- Exqlite.Sqlite3.release(conn.db, statement) do
      topics =
        for [id, name, type] <- flat_topics do
          %Topic{id: id, name: name, type: type}
        end

      {:ok, topics}
    end
  end

  defp start_time(conn), do: timestamp(conn, "ASC")
  defp end_time(conn), do: timestamp(conn, "DESC")

  defp timestamp(conn, order) do
    with {:ok, statement} <-
           Sqlite.prepare(conn.db, "SELECT timestamp FROM messages ORDER BY id #{order} LIMIT 1"),
         {:row, [ts]} <- Sqlite.step(conn.db, statement),
         :ok <- Exqlite.Sqlite3.release(conn.db, statement) do
      DateTime.from_unix(ts, :nanosecond)
    end
  end

  defp update_counters(acc, topic_id) do
    {_, new_counters} =
      Map.get_and_update(acc.counters, topic_id, fn
        nil -> {nil, 1}
        current_value -> {current_value, current_value + 1}
      end)

    %Accumulator{acc | counters: new_counters}
  end

  defp handle_message(acc, topic_id, %Bagsy.GpsFix{} = msg) do
    {_, gnss} =
      Map.get_and_update!(acc.gnss, topic_id, fn current_value ->
        new_value = %Accumulator.Gnss{
          min_latitude: min(current_value.min_latitude, msg.latitude),
          max_latitude: max(current_value.max_latitude, msg.latitude),
          min_longitude: min(current_value.min_longitude, msg.longitude),
          max_longitude: max(current_value.min_longitude, msg.longitude)
        }

        {current_value, new_value}
      end)

    %Accumulator{acc | gnss: gnss}
  end

  defp handle_message(acc, _topic_id, %Bagsy.CompressedImage{} = _msg) do
    acc
  end

  defp handle_message(acc, _topic_id, %Bagsy.WheelSpeed{} = _msg) do
    acc
  end
end
