// § ifcOwnTdTransitiveTfOrder460 (functions in both packages and an own task)
package u;
  typedef logic [3:0] nib_t;
  function int uf(); return 1; endfunction
  class K; extern function int km(); endclass
  function int K::km(); return 2; endfunction
endpackage
package a;
  import u::*;
  typedef int own_t;
  function int af(); return 3; endfunction
endpackage
interface bfm (input logic clk);
  import a::*;
  task it(); endtask
  int r;
  initial r = af();
endinterface
module top;
  logic clk;
  bfm i (.clk(clk));
endmodule
