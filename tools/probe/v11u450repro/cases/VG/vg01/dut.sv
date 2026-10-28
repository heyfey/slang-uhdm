// § importGroupOrderIfaces450
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
package p;
  class C;
    extern function void a1();
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
    extern function void z9();
  endclass
  function void C::a1(); endfunction
  `M_GET(byte)
  `M_GET(int)
  function void C::z9(); endfunction
  function automatic int pf(); return 1; endfunction
endpackage
package q;
  import p::*;
endpackage
interface bfm (input logic clk);
  import q::*;
  function void own_b(); endfunction
  function void own_a(); endfunction
  task own_t(); endtask
endinterface
module top;
  logic clk;
  bfm u (.clk(clk));
endmodule
