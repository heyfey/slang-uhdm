// § macroCloneLoopVarPerSub449
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
   foreach (stream[i]) begin \
      stream[i] = 0; \
   end \
endfunction
package p;
  class C;
    extern function void get_bytes (ref byte unsigned stream[]);
    extern function void get_ints (ref int unsigned stream[]);
  endclass
  `M_GET(byte)
  `M_GET(int)
endpackage
package r;
  import p::*;
  int k;
endpackage
package r2;
  import p::*;
  int k2;
endpackage
module top;
  import r::*;
  import r2::*;
endmodule
