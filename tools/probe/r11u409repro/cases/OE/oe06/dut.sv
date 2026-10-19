// § oobEventTrigHoistNet409
package p;
  class c;
    extern task t();
  endclass
  task c::t();
    event le;
    -> le;
  endtask
endpackage
module top;
  import p::*;
endmodule
