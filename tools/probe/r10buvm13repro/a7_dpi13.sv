// vbuvm13 arm a7 — a DPI-C import PROTOTYPE whose formal carries a DEFAULT
// naming an earlier formal (slang accepts it), at package, module and $unit
// scope, and inside a class.  The DPI prototype has no body at all, so it is
// the one site where "binds like the body" has no body to bind like.
package pd7;
  import "DPI-C" function int d_pkg(input int a, input int b = a);
  import "DPI-C" context function int d_ctx(input int a, input int b = a);
endpackage
import "DPI-C" function int d_unit(input int a, input int b = a);
module m_a7;
  import pd7::*;
  import "DPI-C" function int d_mod(input int a, input int b = a);
  int z;
  initial begin
    z = d_pkg(1); z = d_ctx(1); z = d_unit(1); z = d_mod(1);
  end
endmodule
