// § enumAliasClone161 § enumAliasBaseAsTarget164v — module enum whose base is bounded by a package parameter, aliased in the module
package wp;
  parameter int W = 3;
endpackage
module top(output logic [2:0] o);
  typedef enum logic [wp::W-1:0] { A = 3'd1, B = 3'd5 } e_t;
  typedef e_t f_t;
  f_t v;
  assign v = B;
  assign o = v;
endmodule
