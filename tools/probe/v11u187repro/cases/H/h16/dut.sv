// § defCloneRefsBindDefListing183 (extern method, a module handle calls it)
package p;
int unsigned base = 7;
class c;
  extern function int unsigned get();
endclass
function int unsigned c::get(); return base + 1; endfunction
endpackage
module top(output int unsigned o);
  import p::*;
  c h;
  initial begin h = new; o = h.get(); end
endmodule
