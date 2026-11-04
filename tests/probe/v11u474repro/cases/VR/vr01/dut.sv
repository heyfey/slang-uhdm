// § clsScopedRangeKept474 (attack: module function local)
package p; class S; localparam w = 8; endclass endpackage
module top(output logic [7:0] o);
  import p::*;
  function automatic logic [7:0] f(input logic [7:0] i);
    logic [S::w-1:0] t;
    t = i; return t;
  endfunction
  assign o = f(8'h3);
endmodule
