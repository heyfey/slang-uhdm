// § clsScopedRangeKept474 (attack: class method local)
package p; class S; localparam w = 8; endclass endpackage
package q;
  import p::*;
  class C;
    function int g();
      logic [S::w-1:0] t;
      t = 3; return t;
    endfunction
  endclass
endpackage
module top; import q::*; C c; endmodule
