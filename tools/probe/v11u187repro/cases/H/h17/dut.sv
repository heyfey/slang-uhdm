// § defCloneRefsBindDefListing183 (parameterized class with an untyped parameter)
package p;
int unsigned base = 7;
class c #(W = 2);
  extern function int unsigned get();
endclass
function int unsigned c::get(); return base + W; endfunction
endpackage
module top(output int unsigned o);
  import p::*;
  c #(3) h;
  initial begin h = new; o = h.get(); end
endmodule
