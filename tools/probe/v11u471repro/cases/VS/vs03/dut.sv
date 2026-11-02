// § enumSharedCloneHomeInst471
// enum typedef re-typedefed in importer, shared among two more
package a;
  typedef enum logic [2:0] {S0, S1, S2, S3} st_t;
  parameter st_t PS = S3;
endpackage
package b;
  import a::*;
  typedef st_t st2_t;
endpackage
package c;
  import a::*;
endpackage
package d;
  import a::*;
endpackage
module top(output logic [2:0] y);
  assign y = 3'd1;
endmodule
