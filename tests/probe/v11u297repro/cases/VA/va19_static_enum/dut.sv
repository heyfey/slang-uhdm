// § varDeclInitElabSpan297
typedef enum logic [1:0] { A, B, C } e_t;
module dut(output logic [1:0] o);
  static e_t x = C;
  assign o = x;
endmodule
