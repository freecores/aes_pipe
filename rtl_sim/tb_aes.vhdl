----------------------------------------------------------------------
----                                                              ----
---- Copyright (C) 2001, 2002 Authors                             ----
----                                                              ----
---- This source file may be used and distributed without         ----
---- restriction provided that this copyright statement is not    ----
---- removed from the file and that any derivative work contains  ----
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
---- PURPOSE.  See the GNU Lesser General Public License for more ----
---- details.                                                     ----
----                                                              ----
---- You should have received a copy of the GNU Lesser General    ----
---- Public License along with this source; if not, download it   ----
---- from http:--www.opencores.org/lgpl.shtml                     ----
----                                                              ----
----------------------------------------------------------------------
------------------------------------------------------
-- Project: AESFast
-- Author: Subhasis
-- Last Modified: 20/03/10
-- Email: subhasis256@gmail.com
--
-- TODO: Test with NIST test vectors
------------------------------------------------------
--
-- Description: Testbench for AESFast
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity tb_aes is
end tb_aes;

architecture rtl of tb_aes is
signal clk: std_logic;
signal plaintext: datablock;
signal key: datablock;
signal cipher: datablock;
signal start: std_logic := '0';
signal done: std_logic;

component aes_proc is
port(
	clk: in std_logic;
	plaintext: in datablock;
	keyblock: in datablock;
	ciphertext: out datablock
	);
end component;

begin
	g0: for i in 3 downto 0 generate
		g1: for j in 3 downto 1 generate
			plaintext(i,j) <= X"00";
			key(i,j) <= X"00";
		end generate;
	end generate;
	plaintext(3,0) <= X"00";
	plaintext(2,0) <= X"00";
	plaintext(1,0) <= X"00";
	key(3,0) <= X"00";
	key(2,0) <= X"00";
	key(1,0) <= X"00";
	key(0,0) <= X"00";
	proc0: aes_proc port map(
						clk => clk,
						plaintext => plaintext,
						keyblock => key,
						ciphertext => cipher
					   );
	gen_clk: process
	begin
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		clk <= '0';
	end process;
	
	gen_in: process
	begin
		wait for 25 ns;
		plaintext(0,0) <= X"00";
		wait for 20 ns;
		plaintext(0,0) <= X"01";
		wait for 20 ns;
		plaintext(0,0) <= X"02";
		wait for 40 ns;
		plaintext(0,0) <= X"03";
		wait;
	end process;
end rtl;
