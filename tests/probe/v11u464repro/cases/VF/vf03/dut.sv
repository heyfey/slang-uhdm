// § unitImpTfNameDedup464 (a task name and a function name shared across packages)
package p1;
  task automatic t(output int y); y = 1; endtask
  function automatic int f(int x); return x; endfunction
endpackage
package p2;
  task automatic t(output int y); y = 2; endtask
  function automatic int h(int x); return x; endfunction
endpackage
import p1::*;
import p2::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
