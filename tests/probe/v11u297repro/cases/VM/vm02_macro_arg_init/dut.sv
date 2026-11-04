// § varDeclInitMovesSharedTsEnd297
`define ID(v) v
typedef enum logic [1:0] { A, B, C } e_t;
module dut(output logic [1:0] o);
  var e_t x = `ID(C);
  assign o = x;
endmodule
