// § varDeclInitMovesSharedTsEnd297
typedef struct packed { logic [1:0] a; logic b; } t_t;
module z_m(output logic [2:0] o);
  var t_t x = 3'b001;
  assign o = x;
endmodule
module b_m(output logic [2:0] o);
  const t_t y = {2'b01,
                 1'b0};
  assign o = y;
endmodule
module dut(output logic [2:0] o, output logic [2:0] p);
  z_m ua(.o(o));
  b_m ub(.o(p));
endmodule
