// § enumAliasClone161 — a module alias of a module alias of a module enum
module top(output logic [2:0] o);
  typedef enum logic [2:0] {X = 1, Y = 4} e_t;
  typedef e_t f_t;
  typedef f_t g_t;
  g_t v;
  assign v = Y;
  assign o = v;
endmodule
