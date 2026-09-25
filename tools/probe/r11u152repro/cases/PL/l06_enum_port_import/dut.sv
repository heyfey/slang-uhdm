// § pkgLeafPatLocByWriting152
package pk;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module top import pk::*; (input e_t [2:0] a, output int x);
  assign x = int'(a);
endmodule
