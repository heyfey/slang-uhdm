// § lvStreamBaseKeepsActual258 (an automatic struct local's member select in a task)
module m; typedef struct packed { logic [7:0] f; logic [7:0] g; } s_t; logic [7:0] o;
  task automatic t(input logic [3:0] x); s_t s; {>>{s.f[3:0], s.g[1]}} = {x, 1'b1}; o = s.f; endtask
  initial t(4'h3);
endmodule
module top; m u(); endmodule
