// § enumSharedCloneHomeInst471
// shared enum clone, importers in reverse declaration use, module imports both
package a;
  typedef enum {R, G, B} col_t;
  parameter col_t PC = G;
  localparam col_t LC = B;
endpackage
package c;
  import a::*;
  localparam int NC = 1;
endpackage
package b;
  import a::*;
  localparam int NB = 2;
endpackage
module top(output int y);
  import b::*;
  import c::*;
  assign y = NB + NC;
endmodule
