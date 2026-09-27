// § tpEnumCopyAtTypedef184: enum typedefs sized by the module's header parameter and a localparam, passed as type parameters
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top #(parameter int W = 3) (input logic [W-1:0] a, output logic [W-1:0] b);
  localparam int L = W + 1;
  typedef enum logic [W-1:0] {E0, E1} e_t;
  typedef enum logic [L-1:W-1] {F0, F1} f_t;
  e_t x, y;
  f_t p, q;
  assign x = e_t'(a);
  sub #(.T(e_t)) u (.si(x), .so(y));
  sub #(.T(f_t)) v (.si(p), .so(q));
  assign b = y;
endmodule
