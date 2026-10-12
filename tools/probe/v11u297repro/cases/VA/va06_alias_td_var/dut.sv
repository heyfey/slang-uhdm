// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
typedef t_t t2_t;
module dut(output logic [2:0] o);
  var t2_t x = 3'b011;
  assign o = x;
endmodule
