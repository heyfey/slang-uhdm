// § varDeclInitElabSpan297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  var t_t x = {2'b01,
               1'b1};
  assign o = x;
endmodule
