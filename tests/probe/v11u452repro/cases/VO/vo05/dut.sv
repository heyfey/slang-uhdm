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
  class T;
    int z;
    extern function void read();
  endclass
  function void T::read();
    z = 1;
  endfunction
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule
