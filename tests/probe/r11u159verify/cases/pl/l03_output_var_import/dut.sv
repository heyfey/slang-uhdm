// § pkgLeafPatLocByWriting152
package pk;
  typedef enum logic [1:0] {A, B} s_t;
endpackage
module top import pk::*; (output s_t [1:0] o);
  assign o = '0;
endmodule
