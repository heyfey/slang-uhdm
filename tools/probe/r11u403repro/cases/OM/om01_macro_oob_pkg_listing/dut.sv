// § pkgTfMacroDefAtExpansion403
`define MK_GET(T) \
function void C::get_``T``s(); \
endfunction
package p;
class C;
  extern function void get_bytes();
  extern function void get_ints();
  extern function void set_x();
endclass
`MK_GET(byte)
`MK_GET(int)
function void C::set_x();
endfunction
function void free_f();
endfunction
endpackage
module top; endmodule
