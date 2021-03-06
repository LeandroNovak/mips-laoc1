LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	PORT (
		read_data			:OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);
		MemRead, MemWrite	:IN	STD_LOGIC;
		PC_in					:IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
		ALUOut				:IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		IorD					:IN 	STD_LOGIC;
		clock, reset		:IN	STD_LOGIC);
END dmemory;

ARCHITECTURE behavior OF dmemory IS
	SIGNAL write_clock	:STD_LOGIC;
	SIGNAL write_data		:STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL address			:STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN
	address <= PC_in(7 DOWNTO 0) WHEN IorD = '0' ELSE ALUOut(7 DOWNTO 0);

	data_memory: altsyncram
	GENERIC MAP (
		operation_mode 			=> "SINGLE_PORT",
		width_a 						=> 32,
		widthad_a 					=> 8,
		lpm_type 					=> "altsyncram",
		outdata_reg_a 				=> "UNREGISTERED",
		init_file 					=> "dmemory.mif",
		intended_device_family 	=> "Cyclone")
	
	PORT MAP (
		wren_a 		=> MemWrite,
		clock0 		=> write_clock,
		address_a	=> address,
		data_a 		=> write_data,
		q_a 			=> read_data );
		
		write_clock <= NOT clock;
END behavior;
