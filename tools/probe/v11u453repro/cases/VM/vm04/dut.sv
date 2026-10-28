// § modCopyImportsFirst453
package a;
  int va;
endpackage
package b;
  int vb;
  import a::*;
  class C;
    extern function new();
  endclass
  function C::new();
    int loc;
  endfunction
endpackage
module top;
  import b::*;
endmodule
