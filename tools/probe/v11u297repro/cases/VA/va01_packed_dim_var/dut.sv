// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [5:0] o);
  var t_t [1:0] x = '0;
  assign o = x;
endmodule
