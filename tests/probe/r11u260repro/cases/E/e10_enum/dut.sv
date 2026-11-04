// § castStructInstCopy260 (an enum typedef cast (control))
module m (input logic [1:0] w, output logic [1:0] o);
  typedef enum logic [1:0] { A, B, C } e_t;
  e_t q;
  assign q = e_t'(w);
  assign o = q;
endmodule
module top;
  logic [1:0] w, o;
  m u (.w(w), .o(o));
endmodule
