----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:56:12 11/02/2018 
-- Design Name: 
-- Module Name:    traffic_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity Traffic_Controller is
port( CLK : in std_logic; -- Clock

---clr:in std_logic; -- Clear
rst:in std_logic;

SAR : in std_logic; -- Sensor for right turn from Pymble to Macquarie
---SAT : in std_logic; -- Sensor for through traffic from Pymble to Ryde
SB  : in std_logic; -- Sensor for Waste
SCR : in std_logic; -- Sensor for right turn from Ryde to Waste
--SCT : in std_logic; -- Sensor for through traffic from Ryde to Pymble
SD  : in std_logic; -- Sensor for Macquarie

LAL :out std_logic_vector(2 downto 0);
LAT :out std_logic_vector(2 downto 0);
LAR :out std_logic_vector(2 downto 0);

LBL :out std_logic_vector(2 downto 0);
LBT :out std_logic_vector(2 downto 0);
LBR :out std_logic_vector(2 downto 0);

--LCL :out std_logic_vector(2 downto 0);
LCT :out std_logic_vector(2 downto 0);
LCR :out std_logic_vector(2 downto 0);

--LDL :out std_logic_vector(2 downto 0)
LDT :out std_logic_vector(2 downto 0);
LDR :out std_logic_vector(2 downto 0));

end Traffic_Controller;



architecture Behavioral of Traffic_Controller is

component Clock_Manager is
Port(
clk:	in STD_LOGIC;
S  : out STD_LOGIC
);
end component;

signal clk_sec : std_logic := '0';
---signal clk_ns : std_logic;

type state_TYPE  IS
(S1G,S1Y,S1R,S2G,S2Y,S2R,S3G,S3Y,S3R,S4G,S4Y,S4R,S5G,S5Y,S5R,S6G,S6Y,S6R);
--signal currentstate, nextstate : integer range 0 to 70;   --
---Declaring the current and next states
signal state :state_type;
signal count: std_logic_vector(6 downto 0) :="0000000";
constant sec20:std_logic_vector(6 downto 0) :="0010011"; ---value is 19 as 0- 19
constant sec7:std_logic_vector(6 downto 0)  :="0000110";
constant sec5:std_logic_vector(6 downto 0)  :="0000100";
constant sec1:std_logic_vector(6 downto 0)  :="0000000";
constant clrcount:std_logic_vector(6 downto 0)  :="0000000";

begin
UUT: Clock_Manager  port map (clk => clk, S=> clk_sec);

process(rst, clk_sec)
begin
  if rst='1' then
    state<= S1G;
    count<= clrcount;
 
 elsif (clk_sec'event and clk_sec ='1') then
  ----elsif clk'event and clk = '1'  then
      case state is
       when S1G=>
        if count < sec20 then
            state<= S1G;
            count<= count+ 1;
         elsif(( SB OR SCR OR SD) = '0') then
                             state<= S1G;
              count<= count+ 1;
                    else
              state<=S1Y;
             count <=clrcount;
         end if;

       when S1Y=>
        if count < sec1 then
          state<= S1Y;
          count<= count+1;
         else
                    state<=S1R;
                         count <=clrcount;
        end if; 

                when S1R=>
        if count < sec1 then
          state<= S1R;
          count<= count+1;
        else
                    if SD = '1' then
                    state<=S2G;
                         count <=clrcount;
                         elsif SB = '1' then
             state<=S3G;
                         count <=clrcount;
          elsif SAR = '1' AND SCR ='1' then
                            state<=S4G;
                                 count <=clrcount;
                         elsif SAR = '1' then
                            state<=S5G;
                                 count <=clrcount;
                    elsif SCR = '1' then
                            state<=S6G;
                                 count <=clrcount;
                    end if;     
                  end if;

-- state 2...

       when S2G=>
        if count < sec7 then
            state<= S2G;
            count<= count+ 1;
         elsif(( SAR OR SCR OR SB ) = '0') then
                     state<= S2G;
              count<= count+ 1;
                    else
              state<=S2Y;
                             count <=clrcount;
         end if;

       when S2Y=>
        if count < sec1 then
          state<= S2Y;
          count<= count+1;
         else
                    state<=S2R;
                         count <=clrcount;
        end if; 

                when S2R=>
        if count < sec1 then
          state<= S2R;
          count<= count+1;
        else
                    if SB = '1' AND SD = '1' then
                    state<=S3G;
                         count <=clrcount;
                         elsif SAR = '1' AND SCR = '1' AND SD ='1' then
             state<=S4G;
                         count <=clrcount;
          elsif SAR = '1' AND SD ='1' then
                            state<=S5G;
                                 count <=clrcount;
                         elsif SCR = '1' AND SD = '1' then
                            state<=S6G;
                                 count <=clrcount;
                         else -- default state (Flow 1);
                            state<=S1G;
                                 count <=clrcount;
                    end if;     
                  end if;

 -- flow 3...           

     when S3G=>
        if count < sec5 then
            state<= S3G;
            count<= count+ 1;
         elsif((SAR OR SCR OR SCR or SD) = '0') then
                     state<= S3G;
              count<= count+ 1;
                    else
              state<=S3Y;
                             count <=clrcount;
         end if;

       when S3Y=>
        if count < sec1 then
          state<= S3Y;
          count<= count+1;
         else
                    state<=S3R;
                         count <=clrcount;
        end if; 

                when S3R=>
        if count < sec1 then
          state<= S3R;
          count<= count+1;
        else
                    if SB = '1' AND SAR = '1' AND SCR = '1' then
                    state<=S4G;
                         count <=clrcount;
                         elsif SB = '1' AND SAR = '1' then
             state<=S5G;
                         count <=clrcount;
          elsif SB = '1' AND SCR = '1'  then
                            state<=S6G;
                                 count <=clrcount;

                         else -- default state (Flow 1);
                            state<=S1G;
                                 count <=clrcount;
                    end if;     
                  end if;

-- Flow 4

 -- flow 4...           

     when S4G=>
        if count < sec5 then
            state<= S4G;
            count<= count+ 1;

         else
              state<=S4Y;
             count <=clrcount;
         end if;

       when S4Y=>
        if count < sec1 then
          state<= S4Y;
          count<= count+1;
         else
                    state<=S4R;
                         count <=clrcount;
        end if; 

       when S4R=>
        if count < sec1 then
          state<= S4R;
          count<= count+1;
        else -- default state (Flow 1);
                     
           state<=S1G;
           count <=clrcount;
         end if;      
                
-- flow 5

           when S5G=>
        if count < sec5 then
            state<= S5G;
            count<= count+ 1;
         else
              state<=S5Y;
                             count <=clrcount;
         end if;

       when S5Y=>
        if count < sec1 then
          state<= S5Y;
          count<= count+1;
         else
                    state<=S5R;
                         count <=clrcount;
        end if; 

                when S5R=>
        if count < sec1 then
          state<= S5R;
          count<= count+1;
        else -- default state (Flow 1);
                           state<=S1G;
                          count <=clrcount;
                    end if;     
-- flow 6                       

           when S6G=>
        if count < sec5 then
            state<= S6G;
            count<= count+ 1;
         else
              state<=S6Y;
                             count <=clrcount;
         end if;

       when S6Y=>
        if count < sec1 then
          state<= S6Y;
          count<= count+1;
         else
           state<=S6R;
           count <=clrcount;
             end if; 

          when S6R=>
           if count < sec1 then
          state<= S6R;
          count<= count+1;
            else -- default state (Flow 1);
               state<=S1G;
               count <=clrcount;
                end if;     
         
                 when others => NULL;

                 end case;
                end if; -- clock endif
                end process; -- end processes   



  process(state)
    begin

   case state is

     when S1G =>  -- Mainflow (A - Left green, A - through green, C
---through Green)

     LAL <="001"; LAT <="001"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="001"; LCR <="100";
                  LDT <="100"; LDR <="100";

     when S1Y =>     -- Mainflow turning yellow

     LAL <="010"; LAT <="010"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="010"; LCR <="100";
                  LDT <="100"; LDR <="100";

     When S1R =>  -- Mainflow turning red
     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";

     when S2G => -- Flow 2, Macquarie... D signal

     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="001"; LDR <="001";

     when S2Y =>

     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="010"; LDR <="010";


     When S2R =>
     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";


     when S3G => -- Flow 3, Waste...  B signal

     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="001"; LBT <="001"; LBR <="001";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";

     when S3Y => -- B, Waste signal truning yellow

     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="010"; LBT <="010"; LBR <="010";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";

     When S3R =>
     LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";                                     



     when S4G => -- Flow 4, Diamond

     LAL <="100"; LAT <="100"; LAR <="001";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="001";
                  LDT <="100"; LDR <="100";

     when S4Y => -- flow 4, diamond signal truning yellow

     LAL <="100"; LAT <="100"; LAR <="010";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="010";
                  LDT <="100"; LDR <="100";

     When S4R =>

          LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";



     when S5G => -- Flow 5, Pymble

          LAL <="001"; LAT <="001"; LAR <="001";
          LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";

     when S5Y => -- flow 5, pymble signal truning yellow

     LAL <="001"; LAT <="001"; LAR <="010";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";

     When S5R =>

          LAL <="001"; LAT <="001"; LAR <="100";
          LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="100"; LCR <="100";
                  LDT <="100"; LDR <="100";


     when S6G => -- Flow 6, ryde

          LAL <="100"; LAT <="100"; LAR <="100";
          LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="001"; LCR <="001";
                  LDT <="100"; LDR <="100";

     when S6Y => -- flow 6, ryde signal truning yellow

          LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="001"; LCR <="010";
                  LDT <="100"; LDR <="100";

     When S6R =>

          LAL <="100"; LAT <="100"; LAR <="100";
     LBL <="100"; LBT <="100"; LBR <="100";
                  LCT <="001"; LCR <="100";
                  LDT <="100"; LDR <="100";



     when others => NULL;

   end case;


end process;
end Behavioral;
