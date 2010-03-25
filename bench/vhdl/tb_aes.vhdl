----------------------------------------------------------------------
----                                                              ----
---- Pipelined Aes IP Core                                        ----
----                                                              ----
---- This file is part of the Pipelined AES project               ----
---- http://www.opencores.org/cores/aes_pipe/                     ----
----                                                              ----
---- Description                                                  ----
---- Implementation of AES IP core according to                   ----
---- FIPS PUB 197 specification document.                         ----
----                                                              ----
---- To Do:                                                       ----
----   -                                                          ----
----                                                              ----
---- Author:                                                      ----
----      - Subhasis Das, subhasis256@gmail.com                   ----
----                                                              ----
----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2009 Authors and OPENCORES.ORG                 ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains ----
---- the original copyright notice and the associated disclaimer. ----
----                                                              ----
---- This source file is free software; you can redistribute it   ----
---- and/or modify it under the terms of the GNU Lesser General   ----
---- Public License as published by the Free Software Foundation; ----
---- either version 2.1 of the License, or (at your option) any   ----
---- later version.                                               ----
----                                                              ----
---- This source is distributed in the hope that it will be       ----
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
---- PURPOSE. See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http://www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 25/03/10
-- Email: subhasis256@gmail.com
--
-- TODO: Test with NIST test vectors
------------------------------------------------------
--
-- Description: Testbench for AESFast
-- Takes in data and keys from ../src/vectors.dat
-- Takes in true output values from ../src/cipher.dat
-- Writes all the output to ../log/output.log
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use std.textio.all;

library work;
use work.aes_pkg.all;

entity tb_aes is
end tb_aes;

architecture rtl of tb_aes is
signal clk: std_logic; -- clock
signal plaintext: datablock;
signal key: datablock;
signal cipher: datablock;
signal rst: std_logic; -- reset input
signal op_start: std_logic; -- signal that simulation ended
constant clk_period: time := 10 ns;

component aes_top is
port(
	clk_i: in std_logic;
	rst_i: in std_logic;
	plaintext_i: in datablock;
	keyblock_i: in datablock;
	ciphertext_o: out datablock
	);
end component;

begin
	-- The wiring of the top module
	DUT: aes_top port map(
						 clk_i => clk,
						 rst_i => rst,
						 plaintext_i => plaintext,
						 keyblock_i => key,
						 ciphertext_o => cipher
					 	 );
	-- Generate clock
	gen_clk: process
	begin
		clk <= '1';
		wait for clk_period/2;
		clk <= '0';
		wait for clk_period/2;
	end process;
	-- Generate Reset
	gen_rst: process
	begin
		rst <= '1';
		wait for clk_period/2; -- generate reset
		rst <= '0';
		wait;
	end process;
	
	-- generate the inputs and check against expected output
	gen_in: process
	file testfile: text open read_mode is "../src/vectors.dat";
	variable line_in: line;
	variable plaintext_byte, key_byte: std_logic_vector(7 downto 0);
	begin
		if(endfile(testfile)) then
			file_close(testfile);
			wait;
		end if;
		
		readline(testfile, line_in);
		for i in 3 downto 0 loop
			for j in 3 downto 0 loop
				hread(line_in, plaintext_byte);
				plaintext(3-j,3-i) <= plaintext_byte;
			end loop;
		end loop;
		for i in 3 downto 0 loop
			for j in 3 downto 0 loop
				hread(line_in, key_byte);
				key(3-j,3-i) <= key_byte;
			end loop;
		end loop;
		
		wait for clk_period;
	end process;
	
	-- Generate a signal to indicate that valid output has begun
	op_begin: process
	begin
		wait for 30*clk_period;
		wait for clk_period/2;
		op_start <= '1';
		wait;
	end process;
	
	-- Compare output with actual output file
	op_chk: process
	file chkfile: text open read_mode is "../src/cipher.dat";
	file opfile: text open write_mode is "../log/output.log";
	variable line_in, line_out_file, line_out: line;
	variable exp_cipher_byte: std_logic_vector(7 downto 0);
	variable succeded: boolean;
	begin
		-- if required cycles have passed
		if(op_start = '1') then
			if(endfile(chkfile)) then -- end of simulation
				file_close(chkfile);
				wait;
			end if;
			succeded := true;
			readline(chkfile, line_in); -- read in one expected result
			for i in 3 downto 0 loop
				for j in 3 downto 0 loop
					hread(line_in, exp_cipher_byte); -- read in one byte
					if(exp_cipher_byte /= cipher(3-j,3-i)) then
						succeded := false; -- check failed
					end if;
				end loop;
			end loop;
			-- writing the output line
			for i in 3 downto 0 loop
				for j in 3 downto 0 loop
					hwrite(line_out_file, cipher(3-j,3-i));
					hwrite(line_out, cipher(3-j,3-i));
				end loop;
			end loop;
			write(line_out_file, ' ');
			write(line_out, ' ');
			-- writing the comparison result
			write(line_out_file, succeded);
			write(line_out, succeded);
			writeline(opfile, line_out_file);
			writeline(OUTPUT, line_out);
		end if;
		wait for clk_period;
	end process;
end rtl;
