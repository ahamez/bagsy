defmodule Bagsy.MultiArrayLayout do
  # https://docs.ros2.org/galactic/api/std_msgs/msg/MultiArrayLayout.html

  alias Bagsy.Cdr

  defstruct ~w(dim data_offset)a

  def parse(bytes, offset \\ 0) do
    {length, bytes, offset} = Cdr.uint32(bytes, offset)
    {dim, bytes, offset} = parse_multi_array_dimension([], bytes, offset, length)
    {data_offset, bytes, offset} = Cdr.uint32(bytes, offset)

    {
      %__MODULE__{
        dim: dim,
        data_offset: data_offset
      },
      bytes,
      offset
    }
  end

  defp parse_multi_array_dimension(acc, bytes, offset, 0) do
    {Enum.reverse(acc), bytes, offset}
  end

  defp parse_multi_array_dimension(acc, bytes, offset, length) do
    {dim, bytes, offset} = Bagsy.MultiArrayDimension.parse(bytes, offset)

    parse_multi_array_dimension([dim | acc], bytes, offset, length - 1)
  end
end
