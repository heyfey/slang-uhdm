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
module top;
  sif dn [7:0] ();
  for (genvar i = 0; i < 2; ++i) begin : g
    ileaf a (dn [i]);
  end
endmodule
