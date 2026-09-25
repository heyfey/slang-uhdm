// § ifaceSigConnNamedByChildPort155
interface myif (input logic clk, input logic rst);
  logic sig;
  logic [3:0] dat;
  modport s (input clk, input rst, output sig, input dat);
endinterface
module child (input logic clk, input logic rst, output logic q);
  always_ff @(posedge clk, posedge rst) if (rst) q <= 1'b0; else q <= ~q;
endmodule
module mid (myif.s \sb$0 , output logic q);
  child c (.clk(\sb$0 .clk), .rst(\sb$0 .rst), .q(q));
  assign \sb$0 .sig = q;
endmodule
module dut (input logic clk, input logic rst, output logic q);
  myif mif (.clk(clk), .rst(rst));
  mid m (mif, q);
endmodule
