defmodule Bagsy.Parser do
  defstruct funs: %{}

  def new(topics) do
    %__MODULE__{
      funs: Map.new(topics, &get_parse_fun/1)
    }
  end

  def parse_message(%__MODULE__{} = parser, topic_id, data) do
    # Remove 4-bytes header.
    <<0, 1, 0, 0, data::binary>> = data

    fun = Map.fetch!(parser.funs, topic_id)
    fun.(data)
  end

  # -- Private

  defp get_parse_fun(topic) do
    fun =
      case topic.type do
        "gps_msgs/msg/GPSFix" ->
          &gps_fix/1

        "sensor_msgs/msg/CompressedImage" ->
          &compressed_image/1

        _ ->
          case topic.name do
            "/sensors/wheel_speed" -> &wheel_speed/1
            _ -> &unknown_message_type/1
          end
      end

    {topic.id, fun}
  end

  defp gps_fix(bytes) do
    # It seems 3 bytes are always added at the end (somme padding?)
    {gps_fix, _bytes, _offset} = Bagsy.GpsFix.parse(bytes)

    {:ok, gps_fix}
  end

  defp compressed_image(bytes) do
    {compressed_image, <<>>, _offset} = Bagsy.CompressedImage.parse(bytes)

    {:ok, compressed_image}
  end

  defp wheel_speed(bytes) do
    {wheel_speed, <<>>, _offset} = Bagsy.Float32MultiArray.parse(bytes)

    {:ok, Map.put(wheel_speed, :__struct__, Bagsy.WheelSpeed)}
  end

  defp unknown_message_type(_bytes) do
    :unknown_message_type
  end
end
