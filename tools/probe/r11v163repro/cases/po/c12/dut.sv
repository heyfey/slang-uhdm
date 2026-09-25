// § ovPatOpCopyAtLocalRef163v
typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
module test #(parameter P = '0)(); endmodule
module dut #(parameter r_t HP = '{a: 2'b01, b: 3'd2})();
  test #(.P(HP)) t();
endmodule
module top; dut d(); endmodule
