// § ifcFileScopeImportListing418
package p;
  typedef logic [3:0] nib_t;
  function automatic int f(int a); return a + 1; endfunction
  task automatic t(input int a); endtask
endpackage
import p::*;
interface ifc (input logic clk, output bit [7:0] d);
endinterface
module top;
  logic c;
  wire [7:0] dd;
  ifc u (.clk(c), .d(dd));
endmodule
