// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module child (input logic ck, input logic rs, output logic q);
  always_ff @(posedge ck, posedge rs) if (rs) q <= 1'b0; else q <= ~q;
endmodule
module mid (myif.s sub, output logic q);
  child c (.ck(sub.clk), .rs(sub.rst), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, input logic rst, output logic q);
  myif mif (.clk(clk), .rst(rst));
  mid m (.sub(mif), .q(q));
endmodule
