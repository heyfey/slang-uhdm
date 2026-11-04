// § defNetEndOutputCol171
`define DECL(n) logic [7:0] n [4];
module dut (input logic clk, input logic [7:0] d, output logic [7:0] o);
`DECL(q)
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
