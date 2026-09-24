// § taggedUnionElabSpan137
module top(output logic o);
  typedef union tagged packed { logic [3:0] a; logic [3:0] b; } u_t;
  u_t v, w;
  union tagged packed { logic [1:0] x; logic [1:0] y; } z;
  assign o = v[0] ^ w[1] ^ z[0];
endmodule
