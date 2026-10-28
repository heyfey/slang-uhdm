// § clsOwnProtoAndOobDefBoth452
package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function new();
  endclass
  function S::new();
    y = 1;
  endfunction
endpackage
module top;
  import r::*;
endmodule
