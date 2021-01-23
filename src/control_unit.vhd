----------------------------------------------------------------------------------
-- Company: UERGS
-- Engineer: Joao Leonardo Fragoso
-- 
-- Create Date:    19:08:01 06/26/2012 
-- Design Name:    K and S modeling
-- Module Name:    control_unit - rtl 
-- Description:    RTL Code for K and S control unit
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
--          0.02 - moving to Vivado 2017.3
-- Additional Comments: 
-- Commit
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.k_and_s_pkg.all;

entity control_unit is
  port (
    rst_n               : in  std_logic;
    clk                 : in  std_logic;
    branch              : out std_logic;
    pc_enable           : out std_logic;
    ir_enable           : out std_logic;
    write_reg_enable    : out std_logic;
    addr_sel            : out std_logic;
    c_sel               : out std_logic;
    operation           : out std_logic_vector (1 downto 0);
    flags_reg_enable    : out std_logic;
    decoded_instruction : in  decoded_instruction_type;
    zero_op             : in  std_logic;
    neg_op              : in  std_logic;
    unsigned_overflow   : in  std_logic;
    signed_overflow     : in  std_logic;
    ram_write_enable    : out std_logic;
    halt                : out std_logic
    ); --NOVA VERSAO
end control_unit;

architecture rtl of control_unit is

    type state_type is (START1, FETCH, DECODE, NEXT1, NEXT2, ADD1, ADD2, SUB1, SUB2, AND1, AND2, OR1, OR2, LOAD1, LOAD2, STORE1, STORE2, MOVE1, MOVE2, BRANCH1, BZERO, BNEG, NOP);
    signal state : state_type;
    
begin

process(clk, rst_n)
    begin
    if rst_n = '0' and rising_edge(clk) then
        state <= START1;
    elsif(rising_edge(clk)) then
        branch <= '0';
        pc_enable <= '0';
        ir_enable <= '0';
        write_reg_enable <= '0';
        addr_sel <= '0';
        c_sel <= '0';
        operation <= "00";
        ram_write_enable <= '0';
        flags_reg_enable <= '0';
        halt <= '0';
        case state is
            when START1=>
                state <= FETCH;
            when FETCH=>
                ir_enable <= '1';
                state <= DECODE;
            when NEXT1=>
                    branch <= '1';
                    pc_enable <= '1';
                    state <= NEXT2;
            when NEXT2=>
                    state <= FETCH;
            when DECODE=>
                if decoded_instruction = I_LOAD then
                    state <= LOAD1;
                elsif decoded_instruction = I_STORE then
                    state <= STORE1;
                elsif decoded_instruction = I_MOVE then
                    state <= MOVE1;
                elsif decoded_instruction = I_ADD then
                    state <= ADD1;
                elsif decoded_instruction = I_SUB then
                    state <= SUB1;
                elsif decoded_instruction = I_AND then
                    state <= ADD1;
                elsif decoded_instruction = I_OR then
                    state <= SUB1;
                elsif decoded_instruction = I_BRANCH then
                    state <= BRANCH1;
                elsif decoded_instruction = I_BZERO then
                    state <= BZERO;
                elsif decoded_instruction = I_BNEG then
                    state <= BNEG;    
                elsif decoded_instruction = I_NOP then
                    state <= NEXT1;
                else
                    state <= NOP;
                end if;
                
            --OPERAÇÕES DE MOVIMENTAÇÃO
            when LOAD1=>
                addr_sel <= '0';
                state <= LOAD2;
            when LOAD2=> 
                c_sel <= '1'; 
                write_reg_enable <= '1';
                state <= NEXT1;
            when STORE1=>
                addr_sel <= '0';
                state <= STORE2;
            when STORE2=>
                write_reg_enable <= '1';
                state <= NEXT1;
            when MOVE1=>
                operation <= "10";
                c_sel <= '0';
                state <= MOVE2;
            when MOVE2=>
                write_reg_enable <= '1';
                state <= NEXT1;
                
            --OPERAÇÕES ARITMÉTICAS
            when ADD1=>
                operation <= "00";
                c_sel <= '0';
                state <= ADD2;
            when ADD2=>
                write_reg_enable <= '1';
                state <= NEXT1;
             when SUB1=>
                operation <= "01";
                c_sel <= '0';
                state <= SUB2;
            when SUB2=>
                write_reg_enable <= '1';
                state <= NEXT1;
             when AND1=>
                operation <= "10";
                c_sel <= '0';
                state <= AND2;
            when AND2=>
                write_reg_enable <= '1';
                state <= NEXT1;
            when OR1=>
                operation <= "11";
                c_sel <= '0';
                state <= OR2;
            when OR2=>
                write_reg_enable <= '1';
                state <= NEXT1;
                
            --OPERAÇÕES BRANCH
            when BRANCH1=>
                branch <= '1';
                addr_sel <= '1';
                pc_enable <= '1';
                state <= NEXT2;
            when BZERO=>
                if zero_op<='1' then
                    branch <= '1';
                    addr_sel <= '1';
                    pc_enable <= '1';
                    state <= NEXT2;  
                else
                    state <= NEXT1; 
                end if;
             when BNEG=>
                if neg_op<='1' then
                    branch <= '1';
                    addr_sel <= '1';
                    pc_enable <= '1';
                    state <= NEXT2;  

                else
                    state <= NEXT1;
                end if;
              when others=>
                                     
           end case;
     end if;

end process;


end rtl;

