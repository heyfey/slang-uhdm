// § defCloneRefsBindDefListing183 (a property shadowing a package variable)
package p;
int depth = 2;
int width = 3;
class c;
  int depth;
  function int get(); return depth + width; endfunction
endclass
endpackage
module top(output int o);
  import p::*;
  assign o = width;
endmodule
