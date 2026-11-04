// § importGroupKeepsHomeOrder446
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
`define M_SET(T) \
function void D::set_``T``s (ref T unsigned stream[]); \
  stream = new[2]; \
endfunction
package p;
  class C;
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
  endclass
  class D;
    extern function void set_bytes(ref byte unsigned stream[]);
    extern function void zz();
  endclass
  function void D::zz(); endfunction
  `M_SET(byte)
  `M_GET(int)
  `M_GET(byte)
endpackage
package r;
  function void rr(); endfunction
endpackage
package q;
  import r::*;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
