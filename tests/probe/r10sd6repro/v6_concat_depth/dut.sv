// v6 — a CONCAT (operation) of two references: positive depth control for v1/v5.
package p6;
  logic [3:0] a6 = 4'h5;
  logic [7:0] b6 = {a6, a6};
endpackage
package q6;
  import p6::*;
  class c6;
    int own6;
  endclass
endpackage
module m6;
  q6::c6 h6;
endmodule
