// § castModTypeParamDefaultTs294
// default is a package struct typedef
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; logic [1:0][3:0] m; } c_t;
  localparam c_t C = '{u: 8'h35, d: 8'hA6, m: 8'h21};
endpackage
module top #(parameter type T = pk::in_t) (input logic [7:0] a, output logic [7:0] y);
  always_comb y = T'(a);
endmodule
