// § ifaceSigConnNamedByChildPort155
`define CK sub.clk
interface myif (input logic clk, input logic rst);
  logic sig;
  modport s (input clk, input rst, output sig);
endinterface
module child (input logic clk, input logic rst, output logic q);
  always_ff @(posedge clk, posedge rst) if (rst) q <= 1'b0; else q <= ~q;
endmodule
module mid (myif.s sub, output logic q1, output logic q2);
  child c1 (.clk(`CK), .rst(sub.rst), .q(q1));
  child c2 (.clk(sub.clk), .rst(sub.rst), .q(q2));
  assign sub.sig = q1 ^ q2;
endmodule
module dut (input logic clk, input logic rst, output logic q1, output logic q2);
  myif mif (.clk(clk), .rst(rst));
  mid m (.sub(mif), .q1(q1), .q2(q2));
endmodule
