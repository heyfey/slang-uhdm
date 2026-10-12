// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [1:0] o, output logic p);
  var t_t x = '{a: 2'b11, b: 1'b0};
  assign o = x.a;
  assign p = x.b;
endmodule
