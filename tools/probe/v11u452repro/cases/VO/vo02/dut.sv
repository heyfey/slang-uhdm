// § clsOwnProtoAndOobDefBoth452
package q;
  function void write(int t);
  endfunction
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule
