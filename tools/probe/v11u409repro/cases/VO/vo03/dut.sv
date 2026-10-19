// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    extern task t();
  endclass
  task c::t();
    event le;
    -> le;
    -> e;
    wait (e.triggered);
  endtask
endpackage
module top;
  import p::*;
  logic e;
endmodule
