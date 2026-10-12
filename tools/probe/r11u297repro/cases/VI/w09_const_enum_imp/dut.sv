// § varDeclInitElabSpan297
package pk;
  typedef enum logic [1:0] { A, B, C } e_t;
endpackage
module dut (input logic [7:0] pa, output logic o);
  import pk::*;
  const e_t s = C;
  assign o = (s == C) ^ pa[0];
endmodule
