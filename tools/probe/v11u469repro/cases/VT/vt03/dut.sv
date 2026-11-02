// § importCopyTsInstByRole469
// a packed union typedef parameter
package a;
  typedef union packed { logic [7:0] b; logic [1:0][3:0] n; } u_t;
  parameter u_t PU = 8'h3c;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
