// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  localparam t_t P = 3'b101;
  var t_t x = P;
  assign o = x;
endmodule
