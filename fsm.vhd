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

-- type for states, current implementation uses 4 states, could be reduced to 3
type STATE_TYPE is (no_comment, first_slash, incomment, incomment_block, block_exit);
signal state: STATE_TYPE := no_comment;

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

begin

-- process for FSM for comment checking in C
process (clk, reset)
begin
    -- check to see if FSM is reset
    if reset = '1' then
      state <= no_comment;
      output <= '0';
    -- if not in reset mode run FSM
    elsif rising_edge(clk) then
      case state is
      -- when we are in no_comment check to see if slash is next char
      when no_comment =>
	-- if slash is next char enter "first_slash" state
        if input = SLASH_CHARACTER then
          state <= first_slash;
          output <= '0';
	-- if slash is not next char, stay in no_comment state
        else
          state <= no_comment;
          output <= '0';
        end if;
      -- if we are in first_slash state check to see if next char starts a comment
      when first_slash =>
	-- if next char is a slash enter incomment state
        if input = SLASH_CHARACTER then
          output <= '0';
          state <= incomment;
	-- if next char is a star enter incomment_block state
        elsif input = STAR_CHARACTER then
          output <= '0';
          state <= incomment_block;
	-- else return to no_comment state
        else
          output <= '0';
          state <= no_comment;
        end if;
      -- if we are in incomment state wait to detect new_line char
      when incomment =>
	-- if next char is new_line char then exit comment section
        if input = NEW_LINE_CHARACTER then
          output <= '1';
          state <= no_comment;
	--else wait for new line to exit comment
        else
          output <= '1';
          state <= incomment;
        end if;
      -- if we are in incomment_block wait to detect * char
      when incomment_block =>
	-- if next char is a * char then move to block_exit state
        if input = STAR_CHARACTER then
          output <= '1';
          state <= block_exit;
	--else wait for * char
        else
          output <= '1';
          state <= incomment_block;
        end if;
      -- if we are in block_exit state check next char to see if comment block is over
      when block_exit =>
	-- if next char is a slash then exit comment and return to "no_comment"
        if input = SLASH_CHARACTER then
          output <= '1';
          state <= no_comment;
	--else return to incomment_block state (i.e. we are still in a block comment)
        else
          output <= '1';
          state <= incomment_block;
        end if;
      end case;
    end if;  
end process;

end behavioral;