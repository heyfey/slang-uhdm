// § macroCloneLoopVarPerSub449
`define M_GET(T) \
function void C::get_``T``s (ref T unsigned stream[]); \
   begin : blk \
   foreach (stream[i]) stream[i] = 0; \
   end \
endfunction
package p;
  class C #(int W = 4);
    extern function void get_bytes (ref byte unsigned stream[]);
    extern function void get_ints (ref int unsigned stream[]);
  endclass
  `M_GET(byte)
  `M_GET(int)
  C #(8) c8;
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
