// § ovPatOpCopyAtLocalRef163v
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
endpackage
module test #(parameter P = '0)(); endmodule
module dut();
  localparam pkg::r_t L = '{a: 2'b10, b: 3'd5};
  test #(.P(L)) t();
endmodule
