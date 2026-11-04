// § enumAliasClone161 — a compilation-unit alias of a compilation-unit enum used by a module variable
typedef enum logic [1:0] {A, B, C} e_t;
typedef e_t f_t;
module top(output logic [1:0] o);
  f_t v;
  assign v = B;
  assign o = v;
endmodule
