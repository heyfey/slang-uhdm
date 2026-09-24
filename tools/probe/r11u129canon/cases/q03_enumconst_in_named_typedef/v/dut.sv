package pa; typedef enum logic [1:0] {IDLE, RUN} st_t; endpackage
package pb; typedef enum logic [1:0] {IDLE, RUN} st_t; endpackage
package p;
  typedef struct packed { logic [pb::RUN:0] m; logic n; } s_t;
endpackage
module top(input p::s_t i, output p::s_t o);
  assign o = i;
endmodule
