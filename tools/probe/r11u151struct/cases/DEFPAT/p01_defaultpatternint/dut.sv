// DEFPAT: DefaultPatternInt's shape: a package default-fill array parameter
// imported into a module that reads it in a function.
package pk;
  localparam int unsigned CNT = 2;
  localparam int unsigned V[CNT] = '{default: 3};
endpackage
module top(output int unsigned o);
  import pk::*;
  typedef int unsigned R_T[CNT];
  function static R_T F();
    for (int i = 0; i < CNT; i++) F[i] = V[i];
  endfunction
  localparam int unsigned W[CNT] = F();
  assign o = W[0];
endmodule
