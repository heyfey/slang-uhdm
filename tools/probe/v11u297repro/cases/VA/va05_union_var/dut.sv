// § varDeclInitMovesSharedTsEnd297
typedef union packed { logic [3:0] a; logic [3:0] b; } u_t;
module dut(output logic [3:0] o);
  var u_t x = 4'h3;
  assign o = x.a;
endmodule
