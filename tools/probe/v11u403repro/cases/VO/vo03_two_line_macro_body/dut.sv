// § pkgTfMacroDefAtExpansion403
`define MK(T) \
  function int C::get_``T``(); \
    return 0; \
  endfunction \
  function int C::put_``T``(); \
    return 1; \
  endfunction
package p;
class C;
  extern function int get_a();
  extern function int put_a();
  extern function int other();
endclass
`MK(a)
function int C::other(); return 2; endfunction
endpackage
module top; endmodule
