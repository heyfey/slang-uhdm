// § importCopyTsInstByRole469
// a struct with an enum member as the parameter type
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  typedef struct packed { e_t k; logic [2:0] v; } s_t;
  parameter s_t PS = '{k: E1, v: 3'd5};
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
