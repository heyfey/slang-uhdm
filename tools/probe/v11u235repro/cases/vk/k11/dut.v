// § vlogEnumBaseKwSpan235
module top(output [3:0] o);
  typedef struct packed { enum bit [1:0] {A, B} f; logic [1:0] g; } s_t;
  s_t x;
  enum logic [1:0] {C, D} y, z;
  assign o = {x.f, y};
endmodule
