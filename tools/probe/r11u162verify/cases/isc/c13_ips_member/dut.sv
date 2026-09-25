// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module chd (input logic [1:0] h, input logic clk, output logic q); always_ff @(posedge clk) q <= ^h; endmodule
module mid (myif.s sub, input logic k, output logic q);
  chd c (.h(sub.dat[k +: 2]), .clk(sub.clk), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, input logic rst, input logic k, output logic q);
  myif mif (.clk(clk), .rst(rst));
  mid m (.sub(mif), .k(k), .q(q));
endmodule
