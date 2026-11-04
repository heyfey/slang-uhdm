// § cloneBlockArrElemOwnCopy244
package p;
  class fac;
    task run();
      fork
        begin
          int q[3];
          q[0] = 1;
        end
      join
    endtask
  endclass
endpackage
package q;
  import p::*;
  class u; function void f(); fac x; x = null; endfunction endclass
endpackage
module top; import p::*; import q::*; fac z; u w; initial w = new(); endmodule
