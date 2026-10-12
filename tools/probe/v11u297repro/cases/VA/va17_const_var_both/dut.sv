// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  const var t_t x = 3'b110;
  assign o = x;
endmodule
