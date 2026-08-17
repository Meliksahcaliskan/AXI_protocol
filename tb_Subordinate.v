`timescale 1ns/1ps

module tb_Subordinate;

	reg ACLK;
	reg ARESETn;

	reg [3:0] AW_DATA;
	reg AWVALID;

	reg [3:0] W_DATA;
	reg WVALID;
	
	reg BREADY;
	
	wire AWREADY;
	wire [3:0] AW_read;

	wire WREADY;
	wire [3:0] W_read;

	wire BVALID;


	wire [1:0] state_out;
	
	Subordinate Sub(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		
		.AWVALID(AWVALID),
		.AW_DATA(AW_DATA),

		.AWREADY(AWREADY),
		.AW_read(AW_read),
		

		.WVALID(WVALID),
		.W_DATA(W_DATA),

		.WREADY(WREADY),
		.W_read(W_read),
		
		.BREADY(BREADY),
		.BVALID(BVALID),

		.state_out(state_out)
	);


	initial begin
		ACLK = 1'b0;
		ARESETn = 1'b1;
		AWVALID = 1'b0;
		AW_DATA = 3'b010;
		WVALID = 1'b0;
		W_DATA = 3'b011;
		BREADY = 1'b0;
	end
	
	always #5 ACLK = ~ACLK;
	
	initial begin

		//// Reset testing

		ARESETn = 1'b0;
		#10;
		
		ARESETn = 1'b1;
		
		#2
		
		@(posedge ACLK);
		@(posedge ACLK);
		
		#2
		
		ARESETn = 1'b0;
		
		#10
		
		ARESETn = 1'b1;

		@(posedge ACLK);
		///// Send request

		
		AW_DATA = 3'b101;
		AWVALID = 1'b1;
		@(posedge ACLK);

		if (AWREADY) begin
			AWVALID = 1'b0;
			AW_DATA = 3'b110;
		end else begin
			@(posedge AWREADY);
			@(posedge ACLK);
			AWVALID = 1'b0;
			AW_DATA = 3'b110;
		end
		
		

		W_DATA = 3'b111;
		WVALID = 1'b1;
		@(posedge ACLK);

		if (WREADY) begin
			WVALID = 1'b0;
			W_DATA = 3'b110;
		end else begin
			@(posedge WREADY);
			@(posedge ACLK);
			WVALID = 1'b0;
			W_DATA = 3'b000;
		end

		BREADY = 1'b1;
		@(posedge ACLK);
		
		if (BVALID) begin
			BREADY = 1'b0;
		end else begin
			@(posedge BVALID);
			@(posedge ACLK);
			BREADY = 1'b0;
		end

		#30
		$finish;
	
	end

endmodule