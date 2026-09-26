// § defNetEndOutputCol171
`define CAT(a, b) a``b
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam int W8 = 8;
  logic [`CAT(W, 8)-1:0] q [2];
  assign q[0] = i;
  assign o = q[0];
endmodule
