// § enumSharedCloneHomeInst471
// two enum types in home, importers import home and each other
package a;
  typedef enum {A0, A1} ea_t;
  typedef enum logic {B0, B1} eb_t;
  parameter ea_t PA = A1;
  parameter eb_t PBB = B0;
endpackage
package b; import a::*; parameter int QB = 3; endpackage
package c; import a::*; import b::*; parameter int QC = 4; endpackage
module top(output int y);
  import c::*;
  assign y = QC;
endmodule
