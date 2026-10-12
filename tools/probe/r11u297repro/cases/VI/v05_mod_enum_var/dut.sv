// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef enum logic [1:0] { A, B, C } e_t;
  var e_t s = B;
  assign o = (s == B) ^ pa[0];
endmodule
