// § varDeclInitMovesSharedTsEnd297
`define INIT(v) {2'b01, \
                  v}
typedef struct packed { logic [1:0] a; logic b; } t_t;
module dut(output logic [2:0] o);
  var t_t x = `INIT(1'b1);
  assign o = x;
endmodule
