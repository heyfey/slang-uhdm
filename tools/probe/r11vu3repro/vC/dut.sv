package pc;
  typedef struct packed { logic [3:0] q; logic [3:0] r; } sc_t;
  typedef union packed { logic [7:0] a; logic [7:0] b; } uc_t;
endpackage
module f_int(output int o); parameter int P = 0; assign o = P; endmodule
module top;
  localparam pc::sc_t LC = 8'b10100101;
  parameter  pc::uc_t UC = 8'b11000011;
  int a1, a2, a3;
  f_int #(.P(LC.q)) i1 (.o(a1));
  f_int #(LC.r)     i2 (.o(a2));
  f_int #(.P(UC.a)) i3 (.o(a3));
endmodule
