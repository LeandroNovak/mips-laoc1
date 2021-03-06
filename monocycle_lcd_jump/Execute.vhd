LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Execute IS
	PORT(		
		Read_data_1			:IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Read_data_2			:IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Sign_extend			:IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Function_opcode	:IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALUOp					:IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc				:IN 	STD_LOGIC;
		Zero       			:OUT 	STD_LOGIC;
		ALU_Result			:OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
		Add_Result			:OUT 	STD_LOGIC_VECTOR(7 DOWNTO 0);
		PC_plus_4			:IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
		clock, reset		:IN 	STD_LOGIC);
END Execute;

ARCHITECTURE behavior OF Execute IS
	SIGNAL Ainput, Binput 	:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALU_output_mux	:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Branch_Add			:STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ALU_ctl				:STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN
	Ainput <= Read_data_1;
	
	Binput <= Read_data_2 WHEN ( ALUSrc = '0' )
		ELSE Sign_extend ( 31 DOWNTO 0 );

	ALU_ctl ( 0 ) <= ( Function_opcode ( 0 ) OR Function_opcode ( 3 ) ) AND ALUOp ( 1 );
	ALU_ctl ( 1 ) <= ( NOT Function_opcode ( 2 ) ) OR ( NOT ALUOp ( 1 ) );
	ALU_ctl ( 2 ) <= ( Function_opcode ( 1 ) AND ALUOP ( 1 ) ) OR ALUOp ( 0 );

	Zero <= '1' WHEN ( ALU_output_mux(31 DOWNTO 0) = X"00000000" )
		ELSE '0';

	ALU_result <= X"0000000" & B"000" & ALU_output_mux(31) WHEN ALU_ctl = "11"
		ELSE ALU_output_mux(31 DOWNTO 0);

	Branch_Add <= PC_plus_4(9 DOWNTO 2)  + Sign_extend(7 DOWNTO 0);
	Add_result <= Branch_Add(7 DOWNTO 0);

	PROCESS ( ALU_ctl, Ainput, Binput)
	BEGIN
		CASE ALU_ctl IS
			WHEN "000" => ALU_output_mux <= Ainput AND Binput;
			WHEN "001" => ALU_output_mux <= Ainput OR Binput;
			WHEN "010" => ALU_output_mux <= Ainput + Binput;
			WHEN "100" => ALU_output_mux <= Ainput NOR Binput;
			WHEN "110" => ALU_output_mux <= Ainput - Binput;
			WHEN "111" => ALU_output_mux <= Ainput - Binput;
			WHEN OTHERS => ALU_output_mux <= X"00000000";
		END CASE;
	END PROCESS;
END behavior;
