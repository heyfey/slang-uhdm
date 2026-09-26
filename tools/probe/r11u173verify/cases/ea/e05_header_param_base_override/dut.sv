// § enumAliasClone161 § enumAliasBaseAsTarget164v — module enum bounded by a header parameter, aliased; two instances override it
module sub #(parameter int W = 2) (output logic [W-1:0] o);
  typedef enum logic [W-1:0] { Z = '0, O = 1 } e_t;
  typedef e_t f_t;
  f_t v;
  assign v = O;
  assign o = v;
endmodule
module top(output logic [1:0] a, output logic [3:0] b);
  sub #(.W(2)) u0(.o(a));
  sub #(.W(4)) u1(.o(b));
endmodule
