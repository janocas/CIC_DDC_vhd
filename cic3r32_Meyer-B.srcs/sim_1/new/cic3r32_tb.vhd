library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity cic3r32_tb is
end;

architecture bench of cic3r32_tb is

  component cic3r32
    GENERIC ( R : integer  := 32;
    			D: integer := 2;
    			S : integer := 3;
    			W1 : integer := 16;
    			W2 : integer := 34;
    			W3: integer := 18
    );     
    PORT (clk   : IN  STD_LOGIC;
          reset : IN  STD_LOGIC;
          x_in  : IN  std_logic_vector(W1-1 downto 0);
          clk2  : OUT STD_LOGIC;
          y_out : OUT std_logic_vector(W3-1 downto 0)
    );    
  end component;
constant W1 : integer := 16;
constant W2 : integer := 34;
constant W3: integer := 18;

  signal clk: STD_LOGIC;
  signal reset: STD_LOGIC;
  signal x_in: std_logic_vector(W1-1 downto 0);
  signal clk2: STD_LOGIC;
  signal y_out: std_logic_vector(W3-1 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

begin

  -- Insert values for generic parameters !!
  uut: cic3r32 generic map ( R     => 32,
                             D     => 2,
                             S     => 3,
                             W1    => W1,
                             W2    => W2,
                             W3    =>  W3)
                  port map ( clk   => clk,
                             reset => reset,
                             x_in  => x_in,
                             clk2  => clk2,
                             y_out => y_out );

  stimulus: process
  variable n : integer range 0 to 9999 := 0;
  begin
  
    -- Put initialisation code here

    reset <= '1';
    wait for 5 ns;
    reset <= '0';
    wait for 5 ns;
	
    while (n <= 9999) loop
		wait until falling_edge(clk);
		x_in <= x"0001";
		n := n + 1;
    end loop;
    stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;