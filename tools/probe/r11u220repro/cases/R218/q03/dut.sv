// § pkgQualOperandSpanInParam218
package pk; typedef enum logic [1:0] {E0, E1, E2} e_t; endpackage
module top(output int o);
  localparam int P = pk::E2 + {2{pk::E1}};
  assign o = P;
endmodule
