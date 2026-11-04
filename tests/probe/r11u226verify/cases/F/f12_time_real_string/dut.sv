// § tfArgScalarTdWriter223 — a scalar typedef formal with an unpacked dimension on the formal, a typedef of a signed int with a packed dimension on the typedef, and a mixed port list with plain types
package p;
  typedef integer  IG_T;
  typedef bit signed [15:0] W_T;
  class c;
    function int f(IG_T a [2], int b, W_T w, logic [3:0] l, IG_T z); return b; endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
