// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    extern task run();
  endclass
  task fac::run();
    fork
      begin
        int q[3];
        q[0] = 1;
      end
    join
  endtask
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
