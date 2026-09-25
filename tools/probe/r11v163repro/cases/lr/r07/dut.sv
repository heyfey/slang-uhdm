// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
module test #(parameter P = '0)(); endmodule
module mid #(parameter r_t M = '{a: 2'b11, b: 3'd1})();
  test #(.P(M)) t();
endmodule
module dut();
  mid #(.M('{a: 2'b00, b: 3'd7})) m1();
  mid m2();
endmodule
