// § ovPkgPatOpInstanceCopy163
package pkg;
  localparam logic [2:0] W = 3'd6;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{a: 2'b10, b: W};
endpackage
module test #(parameter P = '0)(); endmodule
module dut();
  test #(.P(pkg::RD)) t();
endmodule
