// § macroCloneLoopVarPerSub449
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
   foreach (stream[i]) begin \
      foreach (stream[j]) stream[j] = stream[i]; \
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
module top;
  import r::*;
endmodule
