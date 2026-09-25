// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{a: 2'b10, b: 3'd5};
endpackage
module test #(parameter P = '0)(output logic [4:0] o); assign o = P; endmodule
module dut(output logic [4:0] o);
  test #(pkg::RD) t(.o(o));
endmodule
