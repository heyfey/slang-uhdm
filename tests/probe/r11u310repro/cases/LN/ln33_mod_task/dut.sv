// § lvNestShapeMidIdxAtSel310
typedef struct packed { logic [3:0] k; logic [3:0] j; } t_t;
typedef struct packed { logic [3:0] k; t_t [3:0] a; } u_t;
typedef struct packed { logic [7:0] f; } e_t;
module top(input logic [1:0] i, input logic [7:0] d, output logic [7:0] r);
  e_t sa [16]; u_t u;
  task automatic put(input logic [1:0] x); sa[u.a[x].k].f = d; endtask
  function automatic void put2(input logic [1:0] x); sa[u.a[x].j].f = d; endfunction
  initial begin put(i); put2(i); end
  assign r = sa[0].f;
endmodule
