// § packedArrTdElemRefName137
// case pd02: a packed-array typedef of an enum used as a sub-module port type
package ep;
  typedef enum logic [1:0] {R = 0, G = 1, Bl = 2} c_t;
  typedef c_t [2:0] ca_t;
endpackage
module sub(input ep::ca_t x, output logic [5:0] o); assign o = x; endmodule
module top(input logic [5:0] i, output logic [5:0] o);
  ep::ca_t w;
  assign w = ep::ca_t'(i);
  sub u(.x(w), .o(o));
endmodule
