// § unitGroupKeepsHomeOrder466
package h;
  function int a1(); return 1; endfunction
  task t1(); endtask
  function int a2(); return 2; endfunction
endpackage
package g;
  import h::*;
  function int gf(); return 7; endfunction
endpackage
function int unitf(); return 5; endfunction
import g::*;
import h::*;
module top(input logic clk, output logic o);
  assign o = clk;
endmodule
