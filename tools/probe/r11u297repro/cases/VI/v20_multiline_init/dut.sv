// § varDeclInitMovesSharedTsEnd297
module dut (input logic [7:0] pa, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x = '{a: 4'h1,
                b: 4'h2};
  assign o = x.a[0] ^ pa[0];
endmodule
