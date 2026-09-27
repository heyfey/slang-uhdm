// § defCloneRefsBindDefListing183 (parameterized class, extern method)
package p;
int unsigned base = 7;
class c #(int W = 2);
  extern function int unsigned get();
endclass
function int unsigned c::get(); return base + W; endfunction
endpackage
module top(output int unsigned o);
  import p::*;
  c #(3) h;
  initial begin h = new; o = h.get(); end
endmodule
