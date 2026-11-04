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
package p2;
  function void zf(); endfunction
  function void af(); endfunction
  function void mf(); endfunction
endpackage
package q2;
  import p2::*;
endpackage
package r;
  import q::*;
  import q2::*;
  class S;
    int k;
  endclass
  class S2;
    extern function void own();
  endclass
  function void S2::own(); endfunction
endpackage
module top;
  import r::*;
endmodule
