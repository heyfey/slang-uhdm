// § tpEnumCopyAtTypedef184: an enum whose base is a typedef name, passed as a type parameter
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top(input logic [3:0] a, output logic [3:0] b);
  typedef logic [3:0] w_t;
  typedef enum w_t {W0 = 4'd1, W1 = 4'd9} we_t;
  we_t x, y;
  assign x = we_t'(a);
  sub #(.T(we_t)) u (.si(x), .so(y));
  assign b = y;
endmodule
