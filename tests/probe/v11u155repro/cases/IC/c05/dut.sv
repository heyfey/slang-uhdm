// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module child (input logic [3:0] d, input logic clk, output logic q);
  always_ff @(posedge clk) q <= ^d;
endmodule
module mid (myif.s sub, output logic q);
  child c (.d(sub.dat), .clk(sub.clk), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, input logic rst, output logic q);
  myif mif (.clk(clk), .rst(rst));
  assign mif.dat = 4'h3;
  mid m (.sub(mif), .q(q));
endmodule
