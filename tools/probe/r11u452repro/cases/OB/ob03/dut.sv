// § clsOwnProtoAndOobDefBoth452
package p;
  function int pf(); return 1; endfunction
endpackage
package r;
  import p::*;
  class S;
    int y;
    extern function void write(int t);
    extern task tk();
  endclass
  function void S::write(int t);
    y = t;
  endfunction
  task S::tk();
  endtask
endpackage
module top;
  import r::*;
endmodule
