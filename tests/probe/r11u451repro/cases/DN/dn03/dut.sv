// § pkgDupSignalLeftoverNet451
package a;
  class K;
    extern function new();
  endclass
  function K::new();
    int loc;
    loc = 1;
  endfunction
  int va;
endpackage
package b;
  import a::*;
  int vb;
endpackage
package c;
  import a::*;
  import b::*;
endpackage
module top;
endmodule
