// § hpSelIdxPkgFoldTsOwner236 — a task body and a final procedural read, package parameter index, depth-3 instances
package pk;
  localparam int N = 2;
  localparam int M = 1;
  typedef struct packed { logic [3:0] q; } f_t;
  typedef struct packed { f_t base; f_t size; } r_t;
endpackage
module leaf import pk::*; (input logic c, output logic [3:0] o);
  r_t [N:0] rc;
  task automatic wr(input logic v);
    rc[N].base.q[0] = v;
  endtask
  always_comb begin
    rc = '0;
    wr(c);
    o = rc[N].base.q;
  end
endmodule
module mid (input logic c, output logic [3:0] o);
  leaf u_l (.c(c), .o(o));
endmodule
module top (input logic c, output logic [3:0] o);
  mid u_m (.c(c), .o(o));
endmodule
