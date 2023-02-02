defmodule Bagsy.MultiArrayDimension do
  # https://docs.ros2.org/galactic/api/std_msgs/msg/MultiArrayDimension.html

  alias Bagsy.Cdr

  defstruct ~w(label size stride)a

  def parse(bytes, offset \\ 0) do
    {label, bytes, offset} = Cdr.string(bytes, offset)
    {size, bytes, offset} = Cdr.uint32(bytes, offset)
    {stride, bytes, offset} = Cdr.uint32(bytes, offset)

    {
      %__MODULE__{
        label: label,
        size: size,
        stride: stride
      },
      bytes,
      offset
    }
  end
end
