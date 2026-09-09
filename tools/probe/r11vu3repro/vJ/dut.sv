package pj;
  typedef struct packed { logic [3:0] g; logic [3:0] h; } sj_t;
endpackage
module sub(output int o);
  parameter pj::sj_t C = 8'b10100101;
  parameter int Q = C.g;
  assign o = Q;
endmodule
module top(output int o);
  sub u (.o(o));
endmodule
