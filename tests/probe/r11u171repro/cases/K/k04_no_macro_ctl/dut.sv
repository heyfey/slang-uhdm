// § defNetEndOutputCol171
module dut #(parameter N = 4) (input logic clk, input logic [15:0] d, output logic [15:0] o);
logic [32/2-1:0]     q_data  [N];
always_ff @(posedge clk) q_data[0] <= d;
assign o = q_data[0];
endmodule
