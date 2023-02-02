defmodule Bagsy.CompressedImage do
  # https://docs.ros2.org/foxy/api/sensor_msgs/msg/CompressedImage.html

  alias Bagsy.{Cdr, Header}

  defstruct [:header, :format, :data]

  def parse(bytes, offset \\ 0) do
    {header, bytes, offset} = Header.parse(bytes, offset)
    {format, bytes, offset} = Cdr.string(bytes, offset)
    {data, bytes, offset} = Cdr.tensor_uint8(bytes, offset)

    {
      %__MODULE__{
        header: header,
        format: format,
        data: data
      },
      bytes,
      offset
    }
  end
end
