----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2024 12:13:16 PM
-- Design Name: 
-- Module Name: cic3r32 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

PACKAGE n_bit_int IS               -- User defined type
  
END n_bit_int;

LIBRARY work;
USE work.n_bit_int.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;
-- --------------------------------------------------------
ENTITY cic3r32 IS
  GENERIC ( R : integer  := 32; -- Sampling factor
  			D: integer := 2; -- Comb delay D
  			S : integer := 3; --  Stages can not change.
  			W1 : integer := 16; -- samples input sz
  			W2 : integer := 34;  -- = W1 + S*log2(DR)= 16 + 18
  			W3: integer := 18 --W1 + 2 -- this needs revision. 
  );     
  PORT (clk   : IN  STD_LOGIC; -- System clock
        reset : IN  STD_LOGIC; -- Asynchronous reset
        x_in  : IN  std_logic_vector(W1-1 downto 0);      -- System input
        clk2  : OUT STD_LOGIC; -- Clock divider
        y_out : OUT std_logic_vector(W3-1 downto 0)   -- System output
  );    
END cic3r32;
-- --------------------------------------------------------
ARCHITECTURE Behavioural OF cic3r32 IS

  SUBTYPE U5 IS INTEGER RANGE 0 TO R;
  
  SUBTYPE SLV10 IS STD_LOGIC_VECTOR(9 DOWNTO 0);


  TYPE    STATE_TYPE IS (hold, sample);
  SIGNAL  state    : STATE_TYPE;
  SIGNAL  count    : U5;
  SIGNAL  x : std_logic_vector(W1-1 downto 0);                  -- Registered input
  SIGNAL  sxtx : std_logic_vector(W2-1 downto 0);              -- Sign extended input
  SIGNAL  i0, i1 , i2 :  std_logic_vector(W2-1 downto 0);    -- I section  0, 1, and 2
  SIGNAL  i2d1, i2d2, c1, c0 :  std_logic_vector(W2-1 downto 0);  
                                    -- I and COMB section 0
  SIGNAL  c1d1, c1d2, c2 :  std_logic_vector(W2-1 downto 0);-- COMB1
  SIGNAL  c2d1, c2d2, c3 :  std_logic_vector(W2-1 downto 0);-- COMB2
      
BEGIN

  FSM: PROCESS (reset, clk) 
  BEGIN
    IF reset = '1' THEN               -- Asynchronous reset
      state <= hold; 
      count <= 0;      
      clk2  <= '0';
    ELSIF rising_edge(clk) THEN  
      IF count = R-1 THEN
        count <= 0;
        state <= sample;
        clk2  <= '1'; 
      ELSE
        count <= count + 1;
        state <= hold;
        clk2  <= '0';
      END IF;
    END IF;
  END PROCESS FSM;

  sxt: PROCESS (x)
  BEGIN
    sxtx(W1-1 DOWNTO 0) <= x;
    FOR k IN W2-1 DOWNTO W1 LOOP
      sxtx(k) <= x(x'high);
    END LOOP;
  END PROCESS sxt;

  Int: PROCESS(clk, reset) 
  BEGIN
    IF reset = '1' THEN -- Asynchronous clear
      x <= (OTHERS => '0');  i0 <= (OTHERS => '0');
      i1 <= (OTHERS => '0');  i2 <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
      x    <= x_in;
      i0   <= i0 + sxtx;        
      i1   <= i1 + i0 ;        
      i2   <= i2 + i1 ; 
    END IF;       
  END PROCESS Int;

  Comb: PROCESS(clk, reset, state)
  BEGIN
    IF reset = '1' THEN -- Asynchronous clear
      c0 <= (OTHERS => '0'); c1 <= (OTHERS => '0');
      c2 <= (OTHERS => '0'); c3 <= (OTHERS => '0');
      i2d1 <= (OTHERS => '0'); i2d2 <= (OTHERS => '0');
      c1d1 <= (OTHERS => '0'); c1d2 <= (OTHERS => '0');
      c2d1 <= (OTHERS => '0'); c2d2 <= (OTHERS => '0');      
    ELSIF rising_edge(clk) THEN
      IF state = sample THEN
        c0   <= i2;
        i2d1 <= c0;
        i2d2 <= i2d1;
        c1   <= c0 - i2d2;
        c1d1 <= c1;
        c1d2 <= c1d1;
        c2   <= c1  - c1d2;
        c2d1 <= c2;
        c2d2 <= c2d1;
        c3   <= c2  - c2d2;
      END IF;
    END IF;  
  END PROCESS Comb;

  y_out <= c3(W2-1 DOWNTO W3-2);  -- i.e., c3 / 2**16

END Behavioural;
