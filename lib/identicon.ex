defmodule Identicon do
  @moduledoc """
  Documentation for Identicon.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello
      :world

  """
  # main(input) method takes the string input and sends input to hash_input method
  # here we use the pipe operation for all the function that we will create
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  # save the image in file system
  def save_image(image, input) do
    File.write("#{input}.png", image)  # writes in filename "input.png" where input
    #input if anshul-- anshul.png etc
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do     # here we do not write %Identicon.Image{color: color, pixel_map: pixel_map}= image
          # as it is the last function and we do not need the image struct in draw_image function
          # but only color and pixel_map
      image = :egd.create(250, 250) # create a image of 250*250 px
      fill = :egd.color(color) #create a color obj with rbg value provided

      # now we create rectangle, Enum.each makes changes in the given content and does not return a new thing like in map
      Enum.each pixel_map, fn({start, stop}) -> 
        :egd.filledRectangle(image, start, stop, fill)
      end
      
      :egd.render(image) #it renders the image 
  end

  #build_pixel_map gibes algo to create the pixel grid
  # use use earlang edg library--- erlang egd(google)
  # egd.create()-- creates a blank image
  # egd.filledRectangle(image, point, point, color)--> 1st point is top-left point of rectangle
  # second point is bottom-right point of rectangle

  # algo, we take 5*5 grid each grid is 50px.
  # so for filling rectangle, we define points
  # top-left--> based on index
  # rem(index, 5)*50--- ex for index 2-- val1=100 (x axis)
  # div(index, 5)*50--- ex for index 2-- val2= 0 (y axis)
  # for bottom-right point add 50 to val1 and val2
  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({ _code, index }) -> 
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left= {horizontal, vertical}

      bottom_right = {horizontal + 50, vertical + 50}

      { top_left, bottom_right }
    end

    %Identicon.Image{ image | pixel_map: pixel_map}
  end

  #filter off square function to get the value and idex which are even
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index} = square) -> 
      rem(code, 2) == 0
    end
    %Identicon.Image{ image | grid: grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
    |> Enum.chunk(3)  
    |> Enum.map(&mirror_row/1) # here we are # passing the reference #to the mirror_row function
                              #we want to know the index for the value in the list
    |> List.flatten   # makes the list flat [ [], [], []] -> [ ]
    |> Enum.with_index       #gives value with index --   [133,21,55]-> [{133,0}, {21,1}, {55,2}]                  
    
    %Identicon.Image{ image | grid: grid}
    # now we want to store this value with index in struct under property grid
  end

  def mirror_row(row) do
    # here we can send only 1 list at a time
    [first, second | _tail] = row
    row ++ [second, first]
  end

  # def pick_color(image) do
  #   # %Identicon.Image{hex: hex_list} = image
  #   # [r, g, b | _tail] = hex_list
  #   # [r, g, b]
  #   # we can write it in short format as
  #   %Identicon.Image{hex: [r, g, b | _tail]} = image
    

  #   # now we want to have bothe the image [r,g,b] and hex binary no list 
  #   # so we create the new entry in the defstruct  call it a color which has value a tuple {r,g,b}
  #   %Identicon.Image{ image | color: {r, g, b}}

  # 
  # end

  # we can write it in this form as well
  def pick_color(%Identicon.Image{hex: [r , g , b | _tail]} = image) do
    %Identicon.Image{ image | color: {r, g, b}}
  end

  # converts the sting into a series of unique number
  def hash_input(input) do
    # :crypto.hash(:md5, input)
    # |> :binary.bin_to_list

    #now we will store this data into the struct we defined
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
