// § varDeclInitMovesSharedTsEnd297
typedef enum logic [1:0] { A, B, C } e_t;
module dut(output logic [1:0] o);
  var e_t x = e_t'(2'd1);
  assign o = x;
endmodule
