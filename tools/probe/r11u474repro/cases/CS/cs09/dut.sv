// § clsScopedRangeKept474 (decode grid)
package p;
  class S;
    localparam w = 16;
  endclass
endpackage
module top (input logic [p::S::w-1:0] i);
  import p::*;
  logic [S::w-1:0] a [S::w];
  function logic [S::w-1:0] f(input logic [S::w-1:0] x); return x; endfunction
endmodule
