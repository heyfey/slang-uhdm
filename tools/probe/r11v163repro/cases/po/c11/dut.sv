// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{a: 2'b10, b: 3'd5};
endpackage
module test #(parameter P = '0)(output logic [1:0] o); assign o = P[4:3]; endmodule
module dut(output logic [1:0] o);
  test #(.P(pkg::RD)) t(.o(o));
endmodule
