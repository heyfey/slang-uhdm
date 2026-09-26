// § defNetEndOutputCol171
`define WID \
  16
`define DEP \
  4
module dut (input logic [15:0] i, output logic [15:0] o);
  logic [`WID-1:0] q [`DEP];
  logic [`WID/2-1:0][1:0] r;
  assign q[0] = i;
  assign r = i;
  assign o = q[0] ^ r;
endmodule
