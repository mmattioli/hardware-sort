--
-- Written by Michael Mattiol
--

library std;
library ieee;
use std.env.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sort_top_tb is
end sort_top_tb;

architecture behavioral of sort_top_tb is

    component sort_top

        generic (   data_elements   : integer := 10;
                    data_width      : integer := 8);

        port (  clk         : in std_logic;
                rst         : in std_logic;
                new_data    : in std_logic_vector (data_width-1 downto 0));

    end component;

    constant clk_period : time := 10 ns;

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal new_data : std_logic_vector (7 downto 0) := (others => '0');

begin

    -- Instantiate the unit under test
    uut : sort_top port map (   clk => clk,
                                rst => rst,
                                new_data => new_data);

    -- Apply the clock
    applied_clk : process
    begin
        wait for clk_period / 2;
        clk <= not clk;
    end process applied_clk;

    -- Apply the stimuli to the unit under test
    stimulus : process
    begin

        new_data <= "00000100"; -- 4
        wait for clk_period;

        new_data <= "00000011"; -- 3
        wait for clk_period;

        new_data <= "00001000"; -- 8
        wait for clk_period;

        new_data <= "00000110"; -- 6
        wait for clk_period;

        new_data <= "00000110"; -- 6
        wait for clk_period;

        new_data <= "00000111"; -- 7
        wait for clk_period;

        new_data <= "00000101"; -- 5
        wait for clk_period;

        new_data <= "00000001"; -- 1
        wait for clk_period;

        new_data <= "00001001"; -- 9
        wait for clk_period;

        new_data <= "00000010"; -- 2
        wait for clk_period;

        new_data <= "00001010"; -- 10
        wait for clk_period;

        -- End simulation
        finish(0);

    end process stimulus;

end;
