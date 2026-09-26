// § enumAliasClone161 — a module enum whose member values are parameter expressions, aliased
module top #(parameter logic [2:0] P = 3'd2) (output logic [2:0] o);
  typedef enum logic [2:0] { A = P, B = P + 3'd1 } e_t;
  typedef e_t f_t;
  f_t v;
  assign v = B;
  assign o = v;
endmodule
