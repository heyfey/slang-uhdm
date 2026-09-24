// § impPaLhsDisjointClone133
package pa;
   parameter int A = 3;
   parameter int B = 5;
endpackage
package pb;
   import pa::*;
   parameter int C = A + B;
endpackage
module top(output int o);
   assign o = pb::C;
endmodule
