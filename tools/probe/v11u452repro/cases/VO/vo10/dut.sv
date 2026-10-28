// § clsOwnProtoAndOobDefBoth452
package q;
  int g;
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
module a;
  import r::*;
endmodule
module top;
  import r::*;
  a u();
endmodule
