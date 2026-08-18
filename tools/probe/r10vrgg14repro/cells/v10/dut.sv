// v10 — the ORDERED (positional) connection spelling and a NAMED one with the
// same text, plus .* / implicit; the ModuleEmit site matches by span/raw text.
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s, input logic q);
  wire w; assign w = s.v & q;
endmodule
module top (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    ileaf a (sarr[3+2*i], arr[0]);          // ordered
    ileaf b (.s (sarr[3+2*i]), .q (arr[0]));// named
    ileaf c (.q (arr[0]), .s (sarr[9+2*i]));// named, reversed order
  end
endmodule
