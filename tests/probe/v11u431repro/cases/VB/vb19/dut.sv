// § unitParamNameBindsDesign431 (an always_ff nonblocking with the name on both sides)
localparam CF = 2;
module top(input clk, input d, output logic q);
logic CF;
always_ff @(posedge clk) begin CF <= d; q <= CF; end
endmodule
