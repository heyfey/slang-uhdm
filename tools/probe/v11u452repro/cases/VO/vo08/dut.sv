// § clsOwnProtoAndOobDefBoth452
package q;
  int g;
endpackage
package r;
  import q::g;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t + g;
  endfunction
endpackage
module top;
  import r::*;
endmodule
