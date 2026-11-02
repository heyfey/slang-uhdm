// § enumSharedCloneHomeInst471
// explicit imports of the enum parameter in two packages
package a;
  typedef enum int {K0 = 3, K1 = 7} k_t;
  parameter k_t PK = K1;
endpackage
package b;
  import a::PK;
endpackage
package c;
  import a::PK;
endpackage
module top;
  logic w;
endmodule
