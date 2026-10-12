// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(o);
  output t_t o;
  var t_t x = 3'b110;
  assign o = x;
endmodule
