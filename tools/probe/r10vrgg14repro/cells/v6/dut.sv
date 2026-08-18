// v6 — genvar NAMED like a parameter, and shadowing: an outer parameter and an
// inner genvar of the same name; plus a genvar shadowed by an inner genvar.
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
module top #(parameter int i = 7, parameter int N = 2) (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar g, i2;
  // the OUTER parameter is named `i`; the genvar is `g`
  for (g = 0; g < 2; ++g) begin : b
    ileaf a (.s (sarr[i+g]));      // parameter + genvar
    ileaf b2 (.s (sarr[i]));       // parameter alone
    nleaf c (.p (arr[i+g]));
    // an inner genvar named the same as an outer LOCALPARAM
    localparam int i2v = 3;
    for (i2 = 0; i2 < 2; ++i2) begin : c2
      ileaf d (.s (sarr[i2v+2*i2+g]));
      nleaf e (.p (arr[i2v+2*i2+g]));
    end
  end
endmodule
