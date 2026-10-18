// § oobMacroDefAtExpansion402
`define DEF_GET(T) function T c::get_``T(); return 0; endfunction
package p;
class c;
  extern function int get_int();
  extern function byte get_byte();
  extern function void zzz();
endclass
function void c::zzz(); endfunction
`DEF_GET(int)
`DEF_GET(byte)
endpackage
module top;
  import p::*;
endmodule
