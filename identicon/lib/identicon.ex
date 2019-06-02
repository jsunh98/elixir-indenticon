defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """
  def main(input) do
    input
    |> hashInput
    |> pickColor
    |> buildGrid
    |> filterOddSquares
    |> buildPixelMap
    |> drawImage
    |> saveImage(input)
  end

  def saveImage(image, input) do
    File.write("#{input}.png", image)
  end

  def drawImage(%Identicon.Image{color: color, pixelMap: pixelMap}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixelMap, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  def buildPixelMap(%Identicon.Image{grid: grid} = image) do
    pixelMap = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      topLeft = {horizontal, vertical}
      bottomRight = {horizontal + 50, vertical + 50}

      {topLeft, bottomRight}
    end
    %Identicon.Image{image | pixelMap: pixelMap}
  end

  def filterOddSquares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  def buildGrid(%Identicon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirrorRow/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end

  def mirrorRow(row) do
    # [145,46,200]
    [first, second | _tail] = row
    # [145,46,200,46,145]
    row ++ [second, first]
  end

  def pickColor(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hashInput(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
