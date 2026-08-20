module Subordinate (
	input ACLK,
	input ARESETn,
	
	input AWVALID,
	input [7:0] AW_DATA,
	
	input WVALID,
	input [63:0] W_DATA,
	
	input BREADY,
	
	output reg WREADY,
	output reg [63:0] W_read,
	
	output reg AWREADY,
	output [7:0] AW_read,

	output reg BVALID,
	
	output [1:0] state_out

);


// Variables
reg [31:0] mem [15:0]; 
reg [7:0] AW;

reg [63:0] data;
reg [1:0] size;
reg [3:0] address;
reg [1:0] len; 
reg [1:0] N;

// State machine
localparam AW_state = 2'b00;
localparam W_state =  2'b01;
localparam B_state =  2'b10;
reg [1:0] state, next_state;


// Interface
assign state_out = state;
assign AW_read = AW;



/// State transition
always @(posedge ACLK) begin
	state <= next_state;
end

/// Control unit
always @(*) begin
	case(state) 
	
		AW_state: if (AWVALID & AWREADY) next_state = W_state;
		
		W_state: if (WVALID & WREADY & (len == 0)) next_state = B_state;

		B_state: if (BVALID & BREADY) next_state = AW_state;
		
		default: next_state = AW_state;
	
	endcase

end


/// Datapath
always @(posedge ACLK or negedge ARESETn) begin
	if (!ARESETn) begin
		AWREADY <= 1'b0;
		WREADY <= 1'b0;

	end else begin
	
		AWREADY <= 1'b1;
		WREADY  <= 1'b1;
		

		case(state)
			AW_state: begin
			
				if(AWVALID & AWREADY) begin
					AW <= AW_DATA;
					AWREADY <= 1'b0;
					size <= AW_DATA[7:6];
					address <= AW_DATA[5:2];
					len <= AW_DATA[1:0];
					N <= 0;
				end
				
			end
			
			W_state:  begin
			
				if(WVALID & WREADY) begin
					mem[address + N] <= (size[1]) ? W_DATA[31:0] : (size[0]) ? W_DATA[15:0] : W_DATA[7:0];
					mem[address + N + 1] <= (size[0] & size[1]) ? W_DATA[63:32] : mem[address + N + 1];
					W_read <= W_DATA;
					WREADY <= (len == 0) ? 1'b0 : 1'b1;
					BVALID <= (len == 0) ? 1'b1 : 1'b0;
					len <= len - 1;
					N <= (size[0] & size[1]) ? N + 2 : N + 1;
				end
				
			end

			B_state:  begin
			
				if(BVALID & BREADY) begin
					BVALID <= 1'b0;
				end else begin
					BVALID <= 1'b1;
				end

				
			end
		endcase
		
		
	end

end


endmodule