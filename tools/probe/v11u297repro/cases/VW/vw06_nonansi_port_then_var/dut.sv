// § varDeclInitElabSpan297
typedef enum logic [1:0] { A, B, C } e_t;
module dut(o);
  output o;
  var e_t o = B;
endmodule
