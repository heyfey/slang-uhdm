package p;
  typedef enum logic [1:0] {IDLE, RUN, DONE} st_t;
  typedef struct packed { logic [3:0] c; st_t s; } in_t;
  typedef struct packed { in_t b; in_t x; } mid_t;
  typedef struct packed { mid_t a; logic [2:0] w; } out_t;
endpackage
module top(input p::out_t i, output logic [3:0] o, output p::st_t s);
  p::out_t r;
  assign r = i;
  assign o = r.a.b.c;
  assign s = r.a.x.s;
endmodule
