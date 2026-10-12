// § varDeclInitMovesSharedTsEnd297
typedef struct packed signed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  var t_t x = -3'sd1;
  assign o = x;
endmodule
