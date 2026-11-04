// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module child (input logic clk, input logic rst, output logic q);
  always_ff @(posedge clk, posedge rst) if (rst) q <= 1'b0; else q <= ~q;
endmodule
module mid (myif.s a, myif.s b, output logic q, output logic q2);
  child c (.clk(a.clk), .rst(b.rst), .q(q));
  child d (.clk(b.clk), .rst(a.rst), .q(q2));
  assign a.sig = q;
  assign b.sig = q2;
endmodule
module dut (input logic clk, input logic rst, output logic q, output logic q2);
  myif mif (.clk(clk), .rst(rst));
  myif mif2 (.clk(rst), .rst(clk));
  mid m (.a(mif), .b(mif2), .q(q), .q2(q2));
endmodule
