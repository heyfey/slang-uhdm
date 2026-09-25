// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic [1:0] a; logic [2:0] b; } r_t;
  parameter r_t RD = '{a: 2'b10, b: 3'd5};
endpackage
interface ti #(parameter P = '0)(); logic [4:0] q; assign q = P; endinterface
module dut();
  ti #(.P(pkg::RD)) t();
endmodule
