// § varDeclInitMovesSharedTsEnd297
package pk;
  typedef enum logic [1:0] { A, B, C } e_t;
endpackage
module dut (input logic [7:0] pa, output logic o);
  import pk::*;
  var e_t s = B;
  assign o = (s == B) ^ pa[0];
endmodule
