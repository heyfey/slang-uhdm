// § pkgLeafPatLocByWriting152
package pk;
  typedef enum logic [1:0] { A, B } e_t;
endpackage
module top import pk::*; (output int x);
  e_t [2:0] a;
  assign a = {A, B, A};
  assign x = int'(a);
endmodule
