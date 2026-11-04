// § memberAnonUnionAtKeyword134
// case n01: an anonymous union member inside a packed union typedef
module top(input logic [7:0] i, output logic [7:0] o);
  typedef union packed {
    union packed { logic [7:0] a; logic [3:0][1:0] b; } inner;
    logic [7:0] w;
  } u_t;
  u_t v;
  assign v.w = i;
  assign o = v.inner.a;
endmodule
