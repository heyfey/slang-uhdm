// § varDeclInitElabSpan297
typedef enum logic [1:0] { A, B, C } e_t;
module c_m(output logic [1:0] o);
  var e_t x = B;
  assign o = x;
endmodule
module dut(output logic [1:0] o, output logic [1:0] p);
  c_m u1(.o(o));
  c_m u2(.o(p));
endmodule
