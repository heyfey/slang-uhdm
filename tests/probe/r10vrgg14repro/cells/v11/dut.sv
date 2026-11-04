// v11 — a gen-for whose body instantiates a module ARRAY of interface-array
// elements, and a gen-for INSIDE a module that is itself instantiated as an
// array (two nested unrollings of the same index expression).
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module mid #(parameter int BASE = 0) (sif.mp s0, sif.mp s1);
  wire w; assign w = s0.v ^ s1.v;
endmodule
module top;
  sif sarr [0:63] ();
  genvar i;
  for (i = 0; i < 3; ++i) begin : g
    mid #(.BASE(i)) m (.s0 (sarr[2*i]), .s1 (sarr[2*i+1]));
    ileaf u [1:0] (.s (sarr[16+i]));
  end
endmodule
