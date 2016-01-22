library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Do not modify the port map of this structure
entity comments_fsm is
port (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
end comments_fsm;

architecture behavioral of comments_fsm is

  
type STATE_TYPE is (SM_0,SM_1,SM_2,SM_3,SM_4);
signal state: STATE_TYPE;

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

begin

-- Insert your processes here
process (clk, reset)
begin
    if reset = '0' then
      state <= SM_0;
      output <= '0';
    elsif rising_edge(clk) then
      case state is
      when SM_0 =>
        if input = SLASH_CHARACTER then
          state <= SM_1;
          output <= '0';
        else
          state <= SM_0;
          output <= '0';
        end if;
      when SM_1 =>
        if input = SLASH_CHARACTER then
          output <= '0';
          state <= SM_2;
        elsif input = STAR_CHARACTER then
          output <= '0';
          state <= SM_3;
        else
          output <= '0';
          state <= SM_0;
        end if;
      when SM_2 =>
        if input = NEW_LINE_CHARACTER then
          output <= '1';
          state <= SM_0;
        else
          output <= '1';
          state <= SM_2;
        end if;
      when SM_3 =>
        if input = STAR_CHARACTER then
          output <= '1';
          state <= SM_4;
        else
          output <= '1';
          state <= SM_3;
        end if;
      when SM_4 =>
        if input = SLASH_CHARACTER then
          output <= '1';
          state <= SM_0;
        else
          output <= '1';
          state <= SM_3;
        end if;
      end case;
    end if;  
end process;

end behavioral;