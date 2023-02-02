defmodule Bagsy.Cdr do
  # https://github.com/eProsima/Fast-CDR/tree/master/src/cpp
  # https://github.com/foxglove/cdr/blob/2b1baa83bd14c9ee7d00c440efc755494e166079/src/CdrReader.ts

  def uint8(bytes, offset) do
    <<value::unsigned-little-8, rest::binary>> = bytes

    {value, rest, offset + 1}
  end

  def uint16(bytes, offset) do
    align = align(offset, 2)
    <<_::binary-size(align), value::unsigned-little-16, rest::binary>> = bytes

    {value, rest, offset + 2 + align}
  end

  def int16(bytes, offset) do
    align = align(offset, 2)
    <<_::binary-size(align), value::signed-little-16, rest::binary>> = bytes

    {value, rest, offset + 2 + align}
  end

  def uint32(bytes, offset) do
    align = align(offset, 4)
    <<_::binary-size(align), value::unsigned-little-32, rest::binary>> = bytes

    {value, rest, offset + 4 + align}
  end

  def float64(bytes, offset) do
    align = align(offset, 8)
    <<_::binary-size(align), value::float-little-64, rest::binary>> = bytes

    {value, rest, offset + 8 + align}
  end

  def float32(bytes, offset) do
    align = align(offset, 4)
    <<_::binary-size(align), value::float-little-32, rest::binary>> = bytes

    {value, rest, offset + 4 + align}
  end

  for {type, nx_type, nb_bytes} <- [
        {:uint8, :u8, 1},
        {:uint32, :u32, 4},
        {:float32, :f32, 4},
        {:float64, :f64, 8}
      ] do
    array_fun = String.to_atom("array_#{type}")
    array_value_fun = String.to_atom("array_#{type}_value")
    tensor_fun = String.to_atom("tensor_#{type}")
    tensor_fun_fixed_size = String.to_atom("tensor_#{type}_fixed_size")
    value_fun = type

    def unquote(array_fun)(bytes, offset) do
      {length, bytes, offset} = uint32(bytes, offset)

      unquote(array_value_fun)([], bytes, offset, length)
    end

    defp unquote(array_value_fun)(acc, bytes, offset, 0) do
      {Enum.reverse(acc), bytes, offset}
    end

    defp unquote(array_value_fun)(acc, bytes, offset, nb_values) do
      {value, bytes, offset} = unquote(value_fun)(bytes, offset)

      unquote(array_value_fun)([value | acc], bytes, offset, nb_values - 1)
    end

    def unquote(tensor_fun)(bytes, offset) do
      {length, bytes, offset} = uint32(bytes, offset)

      unquote(tensor_fun_fixed_size)(bytes, offset, length)
    end

    def unquote(tensor_fun_fixed_size)(bytes, offset, length) do
      align = align(offset, unquote(nb_bytes))
      <<_::binary-size(align), bytes::binary>> = bytes

      length = length * unquote(nb_bytes)
      <<data::binary-size(length), bytes::binary>> = bytes

      {Nx.from_binary(data, unquote(nx_type)), bytes, offset + length}
    end
  end

  def string(bytes, offset) do
    {length, bytes, offset} = uint32(bytes, offset)

    case length do
      0 ->
        {"", bytes, offset}

      length ->
        <<string::binary-size(length - 1), 0, bytes::binary>> = bytes

        {string, bytes, offset + length}
    end
  end

  # -- Private

  defp align(offset, size) do
    case rem(offset, size) do
      0 -> 0
      r -> size - r
    end
  end
end
