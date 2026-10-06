// § castStructInstCopy260 (instance depth 3, the typedef in the leaf module, two leaves)
module leaf (input logic [7:0] w, output logic [3:0] o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  t_t r;
  assign r = t_t'(w);
  assign o = r.b;
endmodule
module mid (input logic [7:0] w, output logic [3:0] o0, o1);
  leaf l0 (.w(w), .o(o0));
  leaf l1 (.w(~w), .o(o1));
endmodule
module top;
  logic [7:0] w; logic [3:0] o0, o1;
  mid m (.w(w), .o0(o0), .o1(o1));
endmodule
