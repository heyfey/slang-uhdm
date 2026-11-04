// § clsOwnProtoAndOobDefBoth452
package q;
  int g;
endpackage
package r;
  import q::*;
  class S;
    int y;
    extern function void write(int t);
    extern task run();
  endclass
  function void S::write(int t);
    y = t;
  endfunction
  task S::run();
    y = 2;
  endtask
endpackage
module top;
  import r::*;
endmodule
