// § varDeclInitElabSpan297
typedef struct { logic [1:0] a; logic b; } us_t;
module dut(output logic [1:0] o);
  var us_t x = '{a: 2'b10, b: 1'b1};
  assign o = x.a;
endmodule
