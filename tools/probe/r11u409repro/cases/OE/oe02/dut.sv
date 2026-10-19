// § oobEventTrigHoistNet409
package p;
  class c;
    event e;
    bit locked;
    function void f();
      locked = 1;
      -> e;
    endfunction
  endclass
endpackage
module top;
  import p::*;
endmodule
