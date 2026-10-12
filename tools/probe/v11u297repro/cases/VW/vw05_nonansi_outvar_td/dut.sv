// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(o);
  output var t_t o = 3'b011;
endmodule
