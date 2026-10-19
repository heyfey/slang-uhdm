// § defImpArithSize32_409
package p;
  typedef bit [27:0] f_t;
  typedef enum f_t { A = 0, B = (1<<16), C = (1<<17) } e_t;
  parameter R = (B|C);
endpackage
import p::*;
module top;
endmodule
