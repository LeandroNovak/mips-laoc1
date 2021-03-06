LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	PORT(		
		read_data_1 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		read_data_2 	: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		read_data 		: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ALU_result 		: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		RegWrite 		: IN	STD_LOGIC;
		MemtoReg 		: IN	STD_LOGIC;
		RegDst 			: IN 	STD_LOGIC;
		clock, reset 	: IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
	TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	SIGNAL register_array					: register_file;
	SIGNAL write_register_address			: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_data							: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	SIGNAL Instruction 						: STD_LOGIC_VECTOR( 31 DOWNTO 0 );

BEGIN
		Instruction <= read_data;

		read_register_1_address			<= Instruction( 25 DOWNTO 21 );
		read_register_2_address			<= Instruction( 20 DOWNTO 16 );
		write_register_address_1		<= Instruction( 15 DOWNTO 11 );
		write_register_address_0		<= Instruction( 20 DOWNTO 16 );
		Instruction_immediate_value	<= Instruction( 15 DOWNTO 0 );

		read_data_1 <= register_array ( CONV_INTEGER (read_register_1_address) );
		read_data_2 <= register_array ( CONV_INTEGER (read_register_2_address) );

		write_register_address <= write_register_address_1 
			WHEN RegDst = '1'
			ELSE write_register_address_0;

		write_data <= ALU_result( 31 DOWNTO 0 ) 
			WHEN( MemtoReg = '0' )
			ELSE read_data;

	PROCESS
	BEGIN
		WAIT UNTIL clock' EVENT AND clock = '1';
		IF reset = '1' THEN
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( i, 32 );
			END LOOP;
		ELSIF RegWrite = '1' AND write_register_address /= 0 THEN
			register_array( CONV_INTEGER( write_register_address) ) <= write_data;
		END IF;
	END PROCESS;
END behavior;
