// § ifcFileScopeImportListing418
package p;
  class C;
    int x;
    function void set(int v); x = v; endfunction
  endclass
  typedef C c_t;
endpackage
import p::*;
interface ifc (input logic clk);
endinterface
module top;
  logic c;
  ifc u (.clk(c));
endmodule
