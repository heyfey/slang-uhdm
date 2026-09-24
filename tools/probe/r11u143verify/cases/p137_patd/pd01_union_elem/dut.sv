// § packedArrTdElemRefName137
// case pd01: a packed-array typedef over a packed union typedef
module top(output logic [7:0] o);
  typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
  typedef u_t [1:0] ua_t;
  ua_t v;
  assign v = 8'h5A;
  assign o = v;
endmodule
