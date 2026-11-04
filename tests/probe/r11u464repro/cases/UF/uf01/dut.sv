// § unitImpTfNameDedup464
package p;
  function automatic int f(int x); return x + 1; endfunction
  task automatic t(output int y); y = 3; endtask
endpackage
package q;
  import p::*;
  function automatic int g(int x); return f(x); endfunction
endpackage
import p::*;
import q::*;
module top(input logic [1:0] i, output logic [1:0] o);
  assign o = i;
endmodule
