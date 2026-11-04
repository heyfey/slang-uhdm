// § importGroupKeepsHomeOrder446
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
package p;
  class C;
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
    extern function void a1();
  endclass
  `M_GET(byte)
  function void C::a1(); endfunction
  `M_GET(int)
endpackage
package p2;
  function void z(); endfunction
  function void y(); endfunction
endpackage
package q;
  import p2::*;
  function void mid(); endfunction
  import p::*;
endpackage
module top;
  import q::*;
endmodule
