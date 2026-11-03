// § clsImpGroupHomeOrder472
`define M_GET(C,T) \
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
  `M_GET(C,byte)
  `M_GET(C,int)
  function void C::z9(); endfunction
endpackage
package p2;
  class K;
    extern function void b1();
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void y8();
  endclass
  function void K::b1(); endfunction
  `M_GET(K,byte)
  function void K::y8(); endfunction
endpackage
package q;
  import p::*;
endpackage
package q2;
  import p2::*;
endpackage
module top;
  import q::*;
  import q2::*;
  class S;
    int k;
  endclass
endmodule
