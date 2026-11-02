// § enumSharedCloneHomeInst471
// enum with explicit values and base, three importers, a program reads one
package a;
  typedef enum bit [3:0] {K1 = 4'h1, K5 = 4'h5, KF = 4'hF} k_t;
  parameter k_t PK = K5;
endpackage
package b; import a::*; endpackage
package c; import a::*; endpackage
package d; import a::*; endpackage
program prg;
  import c::*;
  initial $display("%0d", 1);
endprogram
module top(output logic [3:0] y);
  import d::*;
  assign y = 4'd2;
endmodule
