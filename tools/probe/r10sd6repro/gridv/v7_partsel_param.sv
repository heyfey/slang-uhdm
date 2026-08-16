// v7 — a PART-SELECT whose bounds are references to package PARAMETERS.
package p7;
  parameter int H7 = 3;
  logic [7:0] a7 = 8'h5;
  logic [3:0] b7 = a7[H7:0];
endpackage
package q7;
  import p7::*;
  class c7;
    int own7;
  endclass
endpackage
module m7;
  q7::c7 h7;
endmodule
