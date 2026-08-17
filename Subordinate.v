module Subordinate (
	input ACLK,
	input ARESETn,
	
	input AWVALID,
	input [3:0] AW_DATA,
	
	input WVALID,
	input [3:0] W_DATA,
	
	input BREADY,
	
	output reg WREADY,
	output [3:0] W_read,
	
	output reg AWREADY,
	output [3:0] AW_read,

	output reg BVALID,
	
	output [1:0] state_out

);


// Variables
reg [3:0] mem [15:0]; 
reg [3:0] AW;


// State machine
localparam AW_state = 2'b00;
localparam W_state =  2'b01;
localparam B_state =  2'b10;
reg [1:0] state, next_state;


// Interface
assign state_out = state;
assign AW_read = AW;
assign W_read = mem[0];



/// State transition
always @(*) begin
	state <= next_state;
end

/// Control unit
always @(posedge ACLK) begin
	case(state) 
	
		AW_state: if (AWVALID & AWREADY) next_state <= W_state;
		
		W_state: if (WVALID & WREADY) next_state <= B_state;

		B_state: if (BVALID & BREADY) next_state <= AW_state;
		
		default: next_state <= AW_state;
	
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
		BVALID <= 1'b1;

		case(state)
			AW_state: begin
			
				if(AWVALID & AWREADY) begin
					AW <= AW_DATA;
					AWREADY <= 1'b0;
				end
				
			end
			
			W_state:  begin
			
				if(WVALID & WREADY) begin
					mem[0] <= W_DATA;
					WREADY <= 1'b0;
				end
				
			end

			B_state:  begin
			
				if(BVALID & BREADY) begin
					BVALID <= 1'b0;
				end
				
			end
		endcase
		
		
	end

end


endmodule