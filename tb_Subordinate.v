`timescale 1ns/1ps

module tb_Subordinate;

	reg ACLK;
	reg ARESETn;

	reg [7:0] AW_DATA;
	reg AWVALID;

	reg [63:0] W_DATA;
	reg WVALID;
	
	reg BREADY;
	
	wire AWREADY;
	wire [7:0] AW_read;

	wire WREADY;
	wire [63:0] W_read;

	wire BVALID;


	wire [1:0] state_out;

	integer i;
	
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
		AW_DATA = 8'h00;
		WVALID = 1'b0;
		W_DATA = 64'h0000000000000000;
		BREADY = 1'b0;
	end
	
	always #5 ACLK = ~ACLK;
	
	initial begin

		//// Reset testing

		ARESETn = 1'b0;
		
		@(posedge ACLK);
		
		ARESETn = 1'b1;

		@(posedge ACLK);


		///// Send Request
		AW_DATA = 8'h83;
		AWVALID = 1'b1;
		@(posedge ACLK);

		if (AWREADY) begin
			AWVALID = 1'b0;
		end else begin
			@(posedge AWREADY);
			@(posedge ACLK);
			AWVALID = 1'b0;
		end
		
		//// Send Data
		W_DATA = 64'h0000000000000002;
		for (i = 0; i < 4; i = i+1) begin
			
			
			WVALID = 1'b1;
			@(posedge ACLK);

			if (WREADY) begin
				WVALID = 1'b0;
			end else begin
				@(posedge WREADY);
				@(posedge ACLK);
				WVALID = 1'b0;
			end

			W_DATA = W_DATA + 1;
		
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