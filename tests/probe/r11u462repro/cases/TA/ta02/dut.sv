// § clsMethodOwnAutomatic462
package p;
  class C;
    extern task t();
    extern function int f();
  endclass
  task automatic C::t();
  endtask
  function automatic int C::f();
    return 1;
  endfunction
endpackage
module top;
  import p::*;
  C c;
endmodule
