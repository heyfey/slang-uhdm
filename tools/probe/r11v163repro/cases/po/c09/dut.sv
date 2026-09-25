// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{a: 2'b10, b: 3'd5};
endpackage
module test #(parameter P = '0)(); endmodule
module dut #(parameter pkg::r_t PP = pkg::RD)();
  test #(.P(PP)) t();
endmodule
module top; dut d(); endmodule
