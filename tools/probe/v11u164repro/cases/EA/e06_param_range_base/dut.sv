// § enumAliasClone161 § enumAliasBaseAsTarget164v — a module alias of an enum whose base range is a parameter
module top #(parameter W = 3) (output logic [W-1:0] o);
  typedef enum logic [W-1:0] {A = 0, B = 5} e_t;
  typedef e_t f_t;
  f_t v;
  assign v = B;
  assign o = v;
endmodule
