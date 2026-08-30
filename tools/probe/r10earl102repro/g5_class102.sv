// r10earl102 g5_class102 -- the CLASS home for the same `[0:N-1]` unpacked
// dimension: a class localparam, a parameterized class's own parameter, and
// the same declaration in a package for a side-by-side control.
package p5c102;
  parameter int CN = 2;
  parameter int CPKG [0:CN-1] = '{1, 0};

  class c5_102 #(parameter int CP = 3);
    localparam int CLARR [0:CP-1] = '{2, 1, 0};
    localparam int CPKGARR [0:CN-1] = '{1, 0};
    function int f();
      return CLARR[0] + CPKGARR[0];
    endfunction
  endclass
endpackage

module m5c102
  import p5c102::*;
(
  output int o
);
  c5_102 #(3) h;
  initial h = new();
  assign o = CPKG[0];
endmodule

module g5_class102 (output int o);
  m5c102 u (.o(o));
endmodule
