--
-- Written by Michael Mattiol
--
-- Description: Holds a single data element in a collection of sorted data elements.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sorting_cell is

    generic (data_width : integer := 8); -- 8-bit data storage

    port (  clk                 : in std_logic; -- System clock
            rst                 : in std_logic; -- Global synchronous reset
            new_data            : in std_logic_vector (data_width-1 downto 0); -- New data to be sorted
            prev_cell_data      : in std_logic_vector (data_width-1 downto 0); -- Previous cell's stored data
            prev_cell_occupied  : in boolean; -- Previous cell is occupied or not (empty)
            prev_cell_push      : in boolean; -- Previous cell is pushing data out
            next_cell_data      : out std_logic_vector (data_width-1 downto 0); -- Data to be pushed out
            next_cell_occupied  : out boolean; -- Inform next cell this cell is occupied
            next_cell_push      : out boolean); -- Inform next cell data is being pushed out

end sorting_cell;

architecture behavioral of sorting_cell is

    signal occupied : boolean := false;
    signal current_data : std_logic_vector (data_width-1 downto 0) := (others => '0');
    signal can_accept_data : boolean := false;

begin

    can_accept_data <= (new_data < current_data) or not occupied;
    next_cell_data <= current_data;
    next_cell_occupied <= true when occupied else false;
    next_cell_push <= true when (can_accept_data and occupied) else false;

    state_machine : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                occupied <= false;
            else
                case occupied is
                    when false =>
                        -- Previous cell is pushing data out, this cell must accept it
                        if prev_cell_push then
                            occupied <= true;
                        -- Previous cell is not pushing data out but it is already occupied so we
                        -- must accept the new data to be sorted
                        elsif not prev_cell_push and prev_cell_occupied then
                            occupied <= true;
                        else
                            occupied <= false;
                        end if;
                    when true =>
                        occupied <= true;
                end case;
            end if;
        end if;
    end process state_machine;

    sort : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_data <= (others => '0');
            else
                -- Previous cell is pushing data out, this cell must accept it
                if prev_cell_push then
                    current_data <= prev_cell_data;
                -- New data to be sorted is less than the current data stored
                elsif can_accept_data and not prev_cell_push and occupied then
                    current_data <= new_data;
                -- Store the largest element in the first empty cell
                elsif not prev_cell_push and not occupied and prev_cell_occupied then
                    current_data <= new_data;
                end if;
            end if;
        end if;
    end process sort;

end behavioral;
