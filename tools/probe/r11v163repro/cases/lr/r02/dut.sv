// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
module test #(parameter P = '0)(); endmodule
module dut();
  for (genvar i = 0; i < 2; i++) begin : g
    localparam r_t L = '{a: 2'b10, b: 3'd5};
    test #(.P(L)) t();
  end
endmodule
