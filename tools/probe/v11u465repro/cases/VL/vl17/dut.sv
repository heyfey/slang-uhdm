// § cloneLvSharesHomeUnitTs465
// a class property queue in a foreach nested under if and begin in an out-of-body task
package h;
  class C;
    int q[$];
    bit en;
    extern task t();
  endclass
  task C::t();
    if (en) begin
      foreach (q[i]) q[i]++;
    end
  endtask
endpackage
package a;
  import h::*;
endpackage
import a::*;
module top;
endmodule
