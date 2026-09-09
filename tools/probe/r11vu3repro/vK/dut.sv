package pk;
  typedef struct packed { logic [3:0] g; logic [3:0] h; int unsigned w; } sk_t;
  function automatic sk_t mk();
    sk_t r;
    r.g = 4'b1010;
    r.h = (1) ? 4'b0101 : 4'b0000;
    r.w = 2;
    return r;
  endfunction
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module top;
  parameter pk::sk_t F = pk::mk();
  int a1, a2, a3;
  f_int #(.P(F.g)) i1 (.o(a1));
  f_int #(.P(F.h)) i2 (.o(a2));
  f_int #(.P(F.w)) i3 (.o(a3));
endmodule
