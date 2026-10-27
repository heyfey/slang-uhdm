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
    extern function void get_longints (ref longint unsigned stream[]);
  endclass
  `M_GET(byte)
  `M_GET(int)
  `M_GET(longint)
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
