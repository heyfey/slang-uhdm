// § varDeclInitMovesSharedTsEnd297
program prg;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } t_t;
  var t_t x = 8'h11;
endprogram
module dut (output logic o);
  assign o = 1'b0;
endmodule
