// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    extern task t();
  endclass
  task c::t();
    @e;
    ->> e;
  endtask
endpackage
module top;
  import p::*;
endmodule
