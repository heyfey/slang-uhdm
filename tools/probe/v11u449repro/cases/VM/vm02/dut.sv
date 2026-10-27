// § macroCloneLoopVarPerSub449
`define M_F(T) \
function automatic void f_``T (ref T stream[$]); \
   foreach (stream[i]) stream[i] = 0; \
endfunction
package p;
  `M_F(byte)
  `M_F(int)
  `M_F(shortint)
endpackage
package r;
  import p::*;
  int k;
endpackage
module top;
  import r::*;
endmodule
