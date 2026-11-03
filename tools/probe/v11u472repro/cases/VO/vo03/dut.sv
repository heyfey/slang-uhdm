// § clsImpGroupHomeOrder472
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
endpackage
package q;
  import p::*;
endpackage
import q::*;
class S;
  int k;
endclass
module top;
  S s;
endmodule
