// § clsOwnProtoAndOobDefBoth452
package q;
  class B;
    virtual function void write(int t);
    endfunction
  endclass
endpackage
package r;
  import q::*;
  class S extends B;
    int y;
    extern virtual function void write(int t);
  endclass
  function void S::write(int t);
    y = t;
  endfunction
endpackage
module top;
  import r::*;
endmodule
