// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{default: '0};
endpackage
module test #(parameter P = '0)(); endmodule
module dut();
  test #(.P(pkg::RD)) t();
endmodule
