// § defCloneRefsBindDefListing183
package p;
int unsigned depth = 4;
class c;
  function int unsigned get(); return depth + 1; endfunction
endclass
endpackage
module top(output int unsigned o);
  import p::*;
  assign o = depth;
endmodule
