// § packedArrTdElemRefName137
// case pd03: a packed-array typedef over a plain logic-vector typedef
module top(output logic [7:0] o);
  typedef logic [3:0] n_t;
  typedef n_t [1:0] nn_t;
  nn_t v;
  assign v = 8'hC3;
  assign o = v;
endmodule
