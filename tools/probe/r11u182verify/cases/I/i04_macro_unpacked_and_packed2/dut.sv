// § defNetEndOutputCol171
`define A 4
`define B 2
module dut (input logic [7:0] i, output logic [7:0] o);
  wire [`A-1:0][`B-1:0] q [`B];
  logic [`A*`B-1:0] r [`A-1:0];
  assign q[0] = i;
  assign r[0] = q[0];
  assign o = r[0];
endmodule
