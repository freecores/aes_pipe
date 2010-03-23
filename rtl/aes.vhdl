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
------------------------------------------------------
--
-- Description: The Overall Processor
-- Ports:
--			clk: System Clock
--			plaintext: Input Plaintext Blocks three at a time
--			keyblock: Input Key Blocks three at a time
--			ciphertext: Output Cipher Block
------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library work;
use work.aes_pkg.all;

entity aes is
port(
	clk: in std_logic;
	start: in std_logic;
	plaintext: in datablock;
	keyblock: in datablock;
	done: out std_logic;
	ciphertext: out datablock
	);
end aes;

architecture rtl of aes is
component aes_proc is
port(
	clk: in std_logic;
	plaintext: in datablock;
	keyblock: in datablock;
	rcon: in std_logic_vector(7 downto 0);
	inmux: in std_logic;
	final: in std_logic;
	op_en: in std_logic;
	ciphertext: out datablock
	);
end component;

component aes_con is
port(
	clk: in std_logic;
	start: in std_logic;
	done: out std_logic;
	op_en: out std_logic;
	inmux: out std_logic;
	final: out std_logic;
	rcon: out std_logic_vector(7 downto 0)
	);
end component;
signal inmux, op_en, final: std_logic;
signal rcon: std_logic_vector(7 downto 0);
begin
	proc0: aes_proc port map(
							clk => clk,
							plaintext => plaintext,
							keyblock => keyblock,
							rcon => rcon,
							inmux => inmux,
							final => final,
							op_en => op_en,
							ciphertext => ciphertext
							);
	con0: aes_con port map(
						  clk => clk,
						  start => start,
						  done => done,
						  op_en => op_en,
						  inmux => inmux,
						  final => final,
						  rcon => rcon
						  );
end rtl;
