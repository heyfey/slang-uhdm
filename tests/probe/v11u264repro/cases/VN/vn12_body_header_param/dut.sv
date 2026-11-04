// § caLvTrailIdxNamesByPath264
typedef struct packed { logic [7:0] en; } s_t;
module sub #(parameter int P = 3) (input logic a, output s_t w);
  assign w.en[P] = a;
  assign w.en[P-1] = ~a;
  assign w.en[7:4] = '0;
  assign w.en[2:0] = '0;
endmodule
module top(input logic a, output s_t w, output s_t v);
  sub u(.a(a), .w(w));
  sub #(.P(5)) u2(.a(a), .w(v));
endmodule
