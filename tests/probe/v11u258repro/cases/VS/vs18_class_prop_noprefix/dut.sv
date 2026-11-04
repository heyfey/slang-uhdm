// § lvStreamBaseKeepsActual258 (a class property part select and a queue element as streaming targets without a this. prefix)
package p;
  class c; logic [7:0] f; logic [7:0] q[$];
    function void w(logic [3:0] x); q.push_back(0); {>>{f[3:0], q[0]}} = {x, 8'h1}; endfunction
  endclass
endpackage
module top; endmodule
