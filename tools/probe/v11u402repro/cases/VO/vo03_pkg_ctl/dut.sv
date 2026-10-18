// § unitOobDefsNotInClass402
package p;
class c;
  extern function int f();
  extern task t();
endclass
function int c::f(); return 1; endfunction
task c::t(); endtask
endpackage
module top;
  import p::*;
endmodule
