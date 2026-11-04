// § impTdParamCaFoldTs471
// typedef with an unpacked-free 2-D packed type, and a typedef from another package
package c;
  typedef logic [1:0][3:0] pk_t;
endpackage
package a;
  import c::*;
  parameter pk_t PP = 8'h3C;
endpackage
module top(output logic [7:0] y);
  import a::*;
  assign y = PP;
endmodule
