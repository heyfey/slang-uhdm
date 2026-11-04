// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module chd (input logic [1:0] d, input logic clk, output logic q); always_ff @(posedge clk) q <= ^d; endmodule
module mid (myif.s sub, output logic q);
  chd c (.d({sub.rst, sub.clk}), .clk(sub.clk), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, input logic rst, output logic q);
  myif mif (.clk(clk), .rst(rst));
  mid m (.sub(mif), .q(q));
endmodule
