// § grpOwnOobGenericCls472
`define M_GET(T) \
function void D::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
package p;
  function void pf(); endfunction
endpackage
package q;
  import p::*;
  class D #(int W = 1);
    extern function void a1();
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
    extern function void z9();
  endclass
  function void D::a1(); endfunction
  `M_GET(byte)
  `M_GET(int)
  function void D::z9(); endfunction
endpackage
package r;
  import q::*;
  class S;
    int k;
  endclass
endpackage
module top;
  import r::*;
endmodule
