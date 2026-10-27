// § importGroupKeepsHomeOrder446
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
package p;
  class C;
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
    extern function void b0();
  endclass
  `M_GET(int)
  function void C::b0(); endfunction
  `M_GET(byte)
endpackage
module top;
  import p::*;
  C c;
endmodule
