// § macroCloneLoopVarPerSub449
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
   T v; \
   foreach (stream[i]) begin \
      v = stream[i]; \
   end \
endfunction
package p;
  class C;
    extern function void get_bytes (ref byte unsigned stream[]);
    extern function void get_shortints (ref shortint unsigned stream[]);
  endclass
  `M_GET(byte)
  `M_GET(shortint)
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
