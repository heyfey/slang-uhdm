package p;
string ver = "v1.0";
class c;
  extern function void report();
endclass
function void c::report();
  $display($sformatf("x %s", ver));
endfunction
endpackage
module top;
  import p::*;
  initial $display(ver);
endmodule
