interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_d2 #(parameter int R = 4)(input logic [R-1:0] p, output logic [R-1:0] q);
  assign q = p;
endmodule
module mid_d2 #(parameter int R = 4)(input logic [R-1:0] p, output logic [R-1:0] q);
  leaf_d2 #(.R(R)) u (p, q);
endmodule
module top;
  logic [5:0] p, q;
  mid_d2 #(.R(6)) m (p, q);
endmodule
