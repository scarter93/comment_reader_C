LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

COMPONENT comments_fsm IS
PORT (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
END COMPONENT;

--The input signals with their initial values
SIGNAL clk, s_reset, s_output: STD_LOGIC := '0';
SIGNAL s_input: std_logic_vector(7 downto 0) := (others => '0');

CONSTANT clk_period : time := 1 ns;
-- The ASCII value for the '/', '*' and end-of-line characters
CONSTANT SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
CONSTANT STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
CONSTANT NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

-- Two random ASCII values that are not slash/star/new_line
CONSTANT test_char1	: std_logic_vector(7 downto 0) := "00111011";
CONSTANT test_char2	: std_logic_vector(7 downto 0) := "01011101";

-- input array of size 10 to allow for test vectors
type input_array is array (9 downto 0) of std_logic_vector(7 downto 0);

-- test case that is no comment that does not include any slash or star
signal test_case_nocomment : input_array := (test_char1,test_char1,test_char1,test_char1,
			test_char1,test_char2,test_char2,test_char2,test_char2,test_char2);
-- test case that is no comment with a slash inside
signal test_case_nocomment_slash : input_array := (test_char1,SLASH_CHARACTER,test_char1,test_char1,
			test_char1,test_char2,test_char2,test_char2,test_char2,test_char2);
-- test case that contains a single line comment
signal test_case_doubleslash : input_array := (test_char2,test_char2,SLASH_CHARACTER,SLASH_CHARACTER,
			test_char1,SLASH_CHARACTER,SLASH_CHARACTER,NEW_LINE_CHARACTER,test_char2,test_char2);
-- test case that contains a block comment
signal test_case_slashstar : input_array := (test_char2,test_char2,SLASH_CHARACTER,STAR_CHARACTER,
			NEW_LINE_CHARACTER,SLASH_CHARACTER,SLASH_CHARACTER,STAR_CHARACTER,SLASH_CHARACTER,test_char2); 

BEGIN
dut: comments_fsm
PORT MAP(clk, s_reset, s_input, s_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 
stim_process: PROCESS
BEGIN 
	-- test case for double slash comment test case
	REPORT "begin test case with double slash comment";
	for i in 9 downto 6 loop
		s_input <= test_case_doubleslash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "no comment, and input backslash should be output = '0'" SEVERITY ERROR;
	end loop;
	
	for i in 5 downto 2 loop
		s_input <= test_case_doubleslash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '1') REPORT "comment section should be output = '1'" SEVERITY ERROR;
	end loop;

	for i in 1 downto 0 loop
		s_input <= test_case_doubleslash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "no comment should be output = '0'" SEVERITY ERROR;
	end loop;
	-- perform reset to verify
	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "reset unsuccessful" SEVERITY ERROR;
	
	-- test block case but reset mid comment to verify reset works
	REPORT "begin test case with double slash comment (to test reset mid comment)";
	for i in 9 downto 6 loop
		s_input <= test_case_doubleslash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "error: no comment, and input backslashcstar should be output = '0'" SEVERITY ERROR;
	end loop;
	
	for i in 5 downto 3 loop
		s_input <= test_case_doubleslash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '1') REPORT "error: comment section should be output = '1'" SEVERITY ERROR;
	end loop;
	-- enable reset mid comment to verify it works
	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "reset unsuccessful" SEVERITY ERROR;
	--test case for block comment to verify FSM
	REPORT "begin test case with block comment";
	for i in 9 downto 6 loop
		s_input <= test_case_slashstar(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "no comment, and input backslash should be output = '0'" SEVERITY ERROR;
	end loop;
	
	for i in 5 downto 1 loop
		s_input <= test_case_slashstar(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '1') REPORT "comment section should be output = '1'" SEVERITY ERROR;
	end loop;

	s_input <= test_case_slashstar(0);
	WAIT FOR 1 * clk_period;
	ASSERT(s_output = '0') REPORT "no comment should be output = '0'" SEVERITY ERROR;
	--reset
	s_reset <= '1';
	WAIT FOR 1 * clk_period;
	s_reset <= '0';
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "reset unsuccessful" SEVERITY ERROR;
	-- test cases that contain to comment sections
	REPORT "begin test case with NO COMMENTS";
	for i in 9 downto 0 loop
		s_input <= test_case_nocomment_slash(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "no comment, and input backslash should be output = '0'" SEVERITY ERROR;
	end loop;
	
	for i in 9 downto 0 loop
		s_input <= test_case_nocomment(i);
		WAIT FOR 1 * clk_period;
		ASSERT(s_output = '0') REPORT "no comment, and input backslash should be output = '0'" SEVERITY ERROR;
	end loop;
    
	WAIT;
END PROCESS stim_process;
END;
