// § defCloneRefsBindDefListing183 (a package function and a method read the variable)
package p;
bit [3:0] mode = 4'h2;
function automatic bit [3:0] fm(); return mode; endfunction
class c;
  function bit [3:0] get(); return mode ^ fm(); endfunction
endclass
endpackage
module top(output bit [3:0] o);
  import p::*;
  assign o = mode;
endmodule
