----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:04:44 06/26/2012 
-- Design Name:    K and S Modeling
-- Module Name:    data_path - rtl 
-- Description:    RTL Code for the K and S datapath
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - Moving Vivado 2017.3
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library work;
use ieee.std_logic_unsigned.all;
use work.k_and_s_pkg.all;

entity data_path is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : in  std_logic;
    pc_enable           : in  std_logic;
    ir_enable           : in  std_logic;
    addr_sel            : in  std_logic;
    c_sel               : in  std_logic;
    operation           : in  std_logic_vector ( 1 downto 0);
    write_reg_enable    : in  std_logic;
    flags_reg_enable    : in  std_logic;
    decoded_instruction : out decoded_instruction_type;
    zero_op             : out std_logic;
    neg_op              : out std_logic;
    unsigned_overflow   : out std_logic;
    signed_overflow     : out std_logic;
    ram_addr            : out std_logic_vector ( 4 downto 0);
    data_out            : out std_logic_vector (15 downto 0);
    data_in             : in  std_logic_vector (15 downto 0)
  );
end data_path;

architecture rtl of data_path is

signal bus_a : std_logic_vector (15 downto 0);
signal bus_b : std_logic_vector (15 downto 0);
signal bus_c : std_logic_vector (15 downto 0);


begin
    zero_op <= '1' when bus_c = "0000000000000000" else '0';
    
    ula : process(bus_a, bus_b, operation)
        begin
        if(operation = "00") then --SOMA
            bus_c <= bus_a + bus_b;
            if (bus_a(15) = '0' AND bus_b(15) = '0') AND bus_c(15) = '1' then
                signed_overflow <= '1'; 
            elsif (bus_a(15) = '1' AND bus_b(15) = '1') AND bus_c(15) = '0' then
                signed_overflow <= '1';
            elsif (bus_a(15) = '0' AND bus_b(15) = '1') AND (bus_a >= (NOT bus_b) - "1") then
               unsigned_overflow <= '1';
            elsif (bus_a(15) = '1' AND bus_b(15) = '0') AND ((NOT bus_a) - "1" <= bus_b) then
               unsigned_overflow <= '1';
            elsif (bus_a(15)='1' and bus_b(15)='1') then
               unsigned_overflow <= '1'; 
            end if;
        elsif(operation = "01") then -- SUB
            bus_c <= bus_b - bus_a;
            if(bus_a(15) = '0' AND bus_b(15) = '1') AND bus_c(15) = '1' then 
            signed_overflow <= '1';     
            elsif (bus_a(15) = '1' AND bus_b(15) = '0') AND bus_c(15) = '0' then
            signed_overflow <= '1';    
            elsif (bus_a(15) = '0' and bus_b(15) = '0') and (bus_a >= bus_b) then
            unsigned_overflow <= '1';
            elsif (bus_a(15) = '1' and bus_b(15) = '1') and ((not bus_a) - "1" <= (not bus_b)-1) then
            unsigned_overflow <= '1';
            elsif (bus_a(15)='1' and bus_b(15)='0') then
            unsigned_overflow <= '1'; 
            end if;
        elsif(operation = "10") then --AND    
            bus_c <= bus_a AND bus_b;
        else
            bus_c <= bus_a OR bus_b; --OR 
        end if;
    end process ula;
        
    
                          
    
    
    
    

end rtl;

