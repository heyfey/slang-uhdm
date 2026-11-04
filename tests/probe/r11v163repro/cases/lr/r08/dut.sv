// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
module test #(parameter P = '0)(); endmodule
module dut();
  localparam r_t L = '{2'b10, 3'd5};
  test #(.P(L)) t();
endmodule
