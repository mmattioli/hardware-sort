--
-- Written by Michael Mattiol
--

library std;
library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sorting_cell_tb is
end sorting_cell_tb;

architecture behavioral of sorting_cell_tb is

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

    constant clk_period : time := 10 ns;

    signal clk                  : std_logic := '0';
    signal rst                  : std_logic := '0';
    signal new_data             : std_logic_vector (data_width-1 downto 0) := (others => '0');
    signal prev_cell_data       : std_logic_vector (data_width-1 downto 0) := (others => '0');
    signal prev_cell_occupied   : boolean := false;
    signal prev_cell_push       : boolean := false;
    signal next_cell_data       : std_logic_vector (data_width-1 downto 0) := (others => '0');
    signal next_cell_occupied   : boolean := false;
    signal next_cell_push       : boolean := false;

begin

    -- Instantiate the unit under test
    uut : sorting_cell port map (   clk => clk,
                                    rst => rst,
                                    new_data => new_data,
                                    prev_cell_data => prev_cell_data,
                                    prev_cell_occupied => prev_cell_occupied,
                                    prev_cell_push => prev_cell_push,
                                    next_cell_data => next_cell_data,
                                    next_cell_occupied => next_cell_occupied,
                                    next_cell_push => next_cell_push);

    -- Apply the clock
    applied_clk : process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process applied_clk;

    -- Apply the stimuli to the unit under test
    stimulus : process
    begin

        -- Assume this is the first element and new data is being presented, the previous cell will
        -- always be occupied and never push data out.
        prev_cell_occupied <= true;
        prev_cell_push <= false;

        -- Store the largest element in the first empty cell
        new_data <= "00000100";
        wait for clk_period / 2;
        assert not next_cell_push;
        wait for clk_period / 2;
        assert (next_cell_occupied and next_cell_data = "00000100");

        -- If new data is less than that currently being stored, this cell should push its data out
        -- and accept/store the new data.
        new_data <= "00000011";
        wait for clk_period / 2;
        assert next_cell_push;
        wait for clk_period / 2;
        assert (next_cell_occupied and next_cell_data = "00000011");

        -- If new data is greater than that currently being stored, this cell should do nothing
        -- (it should remain unchanged).
        new_data <= "00001000";
        wait for clk_period / 2;
        assert not next_cell_push;
        wait for clk_period / 2;
        assert (next_cell_occupied and next_cell_data = "00000011");

        -- Reset
        rst <= '1';
        new_data <= "00000000";
        wait for clk_period;
        rst <= '0';
        assert (not next_cell_occupied and next_cell_data = "00000000" and not next_cell_push);

        -- End simulation
        finish(0);

    end process stimulus;

end;
