// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [3:0] a; logic [3:0] b; } ut_t;
module dut (input logic [7:0] pa, output logic o);
  var ut_t x = 8'h11;
  assign o = x.a[0] ^ pa[0];
endmodule
