// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module child (input logic clk, input logic rst, output logic q);
  always_ff @(posedge clk, posedge rst) if (rst) q <= 1'b0; else q <= ~q;
endmodule
module mid (myif.s sub, output logic q, output logic q2);
  child d (.clk(sub.rst), .rst(sub.clk), .q(q2));
  child c (.clk(sub.clk), .rst(sub.rst), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, input logic rst, output logic q, output logic q2);
  myif mif (.clk(clk), .rst(rst));
  mid m (.sub(mif), .q(q), .q2(q2));
endmodule
