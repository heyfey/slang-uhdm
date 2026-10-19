// § defImpArithSize32_409
package p;
  typedef enum bit [27:0] { A = 0, B = (1<<16), C = (1<<17) } e_t;
  parameter R = (B|C);
endpackage
module top;
endmodule
