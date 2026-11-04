// § defNetEndOutputCol171
`define SZ(n) n``_SIZE
module dut #(parameter Q_SIZE = 4) (input logic clk, input logic [7:0] d, output logic [7:0] o);
logic [7:0]     q  [`SZ(Q)];
always_ff @(posedge clk) q[0] <= d;
assign o = q[0];
endmodule
