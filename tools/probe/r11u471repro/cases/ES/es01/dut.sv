// § enumSharedCloneHomeInst471
// two importing packages share the enum import clone
package a;
  typedef enum logic [2:0] {S0, S1, S2, S3} s_t;
  parameter s_t PS = S3;
endpackage
package b;
  import a::*;
endpackage
package c;
  import a::*;
endpackage
module top;
  logic w;
endmodule
