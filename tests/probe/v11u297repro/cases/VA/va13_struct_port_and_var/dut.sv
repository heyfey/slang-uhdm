// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(input t_t i, output logic [2:0] o);
  var t_t x = 3'b011;
  assign o = x ^ i;
endmodule
