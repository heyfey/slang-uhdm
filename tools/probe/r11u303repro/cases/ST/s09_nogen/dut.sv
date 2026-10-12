// § genConnSelBaseNameTrim303
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module vleaf (input logic [1:0] p);
  wire [1:0] w; assign w = p;
endmodule
module top (input logic [7:0] arr);
  sif dn [3:0] ();
  nleaf n (.p (arr [1]));
  ileaf a (.s (dn [1]));
endmodule
