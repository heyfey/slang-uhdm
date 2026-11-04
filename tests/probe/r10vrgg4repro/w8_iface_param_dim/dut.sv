interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
interface ifc_w8 #(parameter int R = 4) ();
  logic a [R];
  logic [R-1:0] b;
  modport host (output a);
endinterface
module top;
  ifc_w8 #(.R(6)) i ();
endmodule
