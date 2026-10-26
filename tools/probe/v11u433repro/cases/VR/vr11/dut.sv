// § classRetFillUnsized433
class C;
  function logic [3:0] f();
    fork begin end join_none
    return '1;
  endfunction
  task t(); endtask
endclass
function logic [3:0] u(); return '1; endfunction
module top; C c; initial c = new; endmodule
