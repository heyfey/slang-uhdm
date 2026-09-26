// § enumAliasClone161 § enumAliasBaseAsTarget164v — a $unit enum bounded by a $unit parameter expression, aliased in a module
parameter int UW = 4;
typedef enum logic [UW/2-1:0] { U0, U1, U2 } u_e;
module top(output logic [1:0] o);
  typedef u_e u_t;
  u_t v;
  assign v = U2;
  assign o = v;
endmodule
