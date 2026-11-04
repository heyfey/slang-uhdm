// § castStructInstCopy260 (a vector typedef cast (control))
module m (input logic [31:0] w, output logic [5:0] o);
  typedef logic [5:0] v_t;
  v_t q;
  assign q = v_t'(w);
  assign o = q;
endmodule
module top;
  logic [31:0] w; logic [5:0] o;
  m u (.w(w), .o(o));
endmodule
