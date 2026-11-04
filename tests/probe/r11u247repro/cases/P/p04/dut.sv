// § pureVirtFormalSignKwTrim247
package p;
  class c;
    extern function void ext(int unsigned a);
    extern virtual function void ext2(int signed a);
  endclass
  function void c::ext(int unsigned a); endfunction
  function void c::ext2(int signed a); endfunction
endpackage
module top;
  import p::*;
  c x;
endmodule
