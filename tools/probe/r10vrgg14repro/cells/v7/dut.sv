// v7 — WIDE and NEGATIVE folds: >32-bit intermediate values, an index that
// goes negative on the way, and a big literal.
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
module top #(parameter longint BIG = 64'd4294967296) (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    // BIG*0 + i and BIG - BIG + i keep the value small but the arithmetic wide
    ileaf a (.s (sarr[BIG*i - BIG*i + 3 + i]));
    ileaf b (.s (sarr[(BIG - BIG) + 5 + i]));
    ileaf c (.s (sarr[7 - i + i]));
    ileaf d (.s (sarr[(i - 3) + 3 + i]));
    ileaf e (.s (sarr[32'hFFFFFFFF - 32'hFFFFFFF0 + i]));
    nleaf f (.p (arr[(i - 3) + 3 + i]));
    nleaf h (.p (arr[BIG*i - BIG*i + 3 + i]));
  end
endmodule
