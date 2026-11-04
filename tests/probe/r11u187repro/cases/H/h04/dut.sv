// § defCloneRefsBindDefListing183
package p;
string ver = "v1";
class c;
  extern function void rep();
endclass
function void c::rep();
  ver = "v2";
  $display(ver);
endfunction
endpackage
module top;
  import p::*;
  initial begin ver = "x"; $display(ver); end
endmodule
