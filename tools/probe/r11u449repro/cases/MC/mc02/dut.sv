// § macroCloneLoopVarPerSub449
`define M_GET(T) \
function automatic void get_``T``s (ref T unsigned stream[]); \
   foreach (stream[i]) begin \
      stream[i] = 0; \
   end \
endfunction
package p;
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
