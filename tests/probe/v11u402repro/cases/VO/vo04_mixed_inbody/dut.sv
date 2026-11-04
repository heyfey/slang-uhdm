// § unitOobDefsNotInClass402
class c;
  function int inb(); return 2; endfunction
  extern task t();
  extern function void f();
  function void inb2(); endfunction
endclass
task c::t(); endtask
function void c::f(); endfunction
module top;
endmodule
