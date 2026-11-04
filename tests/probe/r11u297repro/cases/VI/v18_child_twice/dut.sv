// § varDeclInitMovesSharedTsEnd297
module child (input logic i, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x = 8'h11;
  assign o = x.a[0] ^ i;
endmodule
module dut (input logic [1:0] i, output logic [1:0] o);
  child u0 (.i(i[0]), .o(o[0]));
  child u1 (.i(i[1]), .o(o[1]));
endmodule
