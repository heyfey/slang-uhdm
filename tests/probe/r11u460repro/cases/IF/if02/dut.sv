// § ifcOwnTdTransitiveTfOrder460
package u;
  typedef logic [3:0] nib_t;
  function int uf(int x); return x; endfunction
  class C;
    extern function int m();
  endclass
  function int C::m(); return 1; endfunction
endpackage
package a;
  import u::*;
  typedef int own_t;
  class D;
    extern function int n();
  endclass
  function int D::n(); return 2; endfunction
endpackage
interface bfm (input logic clk);
  import u::*;
  import a::*;
  task t(); endtask
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
