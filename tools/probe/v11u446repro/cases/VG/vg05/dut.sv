// § importGroupKeepsHomeOrder446
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
  stream = new[1]; \
endfunction
package p;
  class C;
    extern function void a1();
    extern function void get_bytes(ref byte unsigned stream[]);
    extern function void get_ints(ref int unsigned stream[]);
  endclass
  function void C::a1(); endfunction
  `M_GET(byte)
  `M_GET(int)
  function automatic int tail(int a); return a; endfunction
endpackage
package q;
  import p::*;
  export p::*;
  function automatic int qq(int a); return tail(a); endfunction
  C cq;
endpackage
package r;
  import q::*;
  class D;
    C c;
  endclass
endpackage
module top;
  import r::*;
  D d;
endmodule
