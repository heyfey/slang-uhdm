// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o, output logic [2:0] p);
  var t_t x = 3'b101, y;
  assign y = 3'b010;
  assign o = x;
  assign p = y;
endmodule
