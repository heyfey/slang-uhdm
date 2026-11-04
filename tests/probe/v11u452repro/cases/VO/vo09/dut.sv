// § clsOwnProtoAndOobDefBoth452
package q;
  int g;
endpackage
package r;
  import q::*;
  function void free1();
  endfunction
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void free2();
  endfunction
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule
