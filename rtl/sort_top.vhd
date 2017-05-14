--
-- Written by Michael Mattioli
--
--
-- Description: Top-level module of sorting algorithm.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sort_top is

    generic (   data_elements   : integer := 10; -- Can sort up to 10 elements
                data_width      : integer := 8); -- 8-bit data elements

    port (  clk         : in std_logic; -- System clock
            rst         : in std_logic; -- Global synchronous reset
            new_data    : in std_logic_vector (data_width-1 downto 0)); -- New data to be sorted

end sort_top;

architecture behavioral of sort_top is

    component sorting_cell

        generic (data_width : integer := 8);

        port (  clk                 : in std_logic;
                rst                 : in std_logic;
                new_data            : in std_logic_vector (data_width-1 downto 0);
                prev_cell_data      : in std_logic_vector (data_width-1 downto 0);
                prev_cell_occupied  : in boolean;
                prev_cell_push      : in boolean;
                next_cell_data      : out std_logic_vector (data_width-1 downto 0);
                next_cell_occupied  : out boolean;
                next_cell_push      : out boolean);

    end component;

    type data_bus is array (0 to data_elements-1) of std_logic_vector (data_width-1 downto 0);
    type occupied_bus is array (0 to data_elements-2) of boolean;
    type push_bus is array (0 to data_elements-2) of boolean;

    signal cell_data       : data_bus;
    signal cell_occupied   : occupied_bus;
    signal cell_push       : push_bus;

begin
    sorted_data : for cell in 0 to data_elements-1 generate

        -- For the first cell, we force prev_cell_occupied as `true` and don't care about the values
        -- of prev_cell_data and prev_cell_push because this is the first element so it can't take
        -- data from something that doesn't exist.
        first_cell : if cell = 0 generate
            begin first_cell : sorting_cell port map (  clk => clk,
                                                        rst => rst,
                                                        new_data => new_data,
                                                        prev_cell_data => (others => '0'),
                                                        prev_cell_occupied => true,
                                                        prev_cell_push => false,
                                                        next_cell_data => cell_data(cell),
                                                        next_cell_occupied => cell_occupied(cell),
                                                        next_cell_push => cell_push(cell));
        end generate first_cell;

        -- For the last cell, we don't connect the `next_cell_` values because it's the last element
        -- so those values are useless; we only connect `next_cell_data` so that the bus is informed
        -- of the last element's current data value.
        last_cell : if cell = data_elements-1 generate
            begin last_cell : sorting_cell port map (   clk => clk,
                                                        rst => rst,
                                                        new_data => new_data,
                                                        prev_cell_data => cell_data(cell-1),
                                                        prev_cell_occupied => cell_occupied(cell-1),
                                                        prev_cell_push => cell_push(cell-1),
                                                        next_cell_data => cell_data(cell));
        end generate last_cell;

        -- For every other cell in the collection, we connect the `prev_cell_` values to the
        -- previous cell's `next_cell_` values and the `next_cell_` values to the next cell's
        -- `prev_cell_` values.
        regular_cells : if (cell /= 0) and (cell /= data_elements-1) generate
            begin regular_cells : sorting_cell port map (   clk => clk,
                                                            rst => rst,
                                                            new_data => new_data,
                                                            prev_cell_data => cell_data(cell-1),
                                                            prev_cell_occupied => cell_occupied(cell-1),
                                                            prev_cell_push => cell_push(cell-1),
                                                            next_cell_data => cell_data(cell),
                                                            next_cell_occupied => cell_occupied(cell),
                                                            next_cell_push => cell_push(cell));
            end generate regular_cells;
    end generate sorted_data;
end behavioral;
