// § enumSharedCloneHomeInst471
// a chain c -> b -> a plus a direct importer d of a
package a;
  typedef enum logic [1:0] {E0, E1, E2} e_t;
  parameter e_t PE = E2;
endpackage
package b;
  import a::*;
endpackage
package c;
  import b::*;
endpackage
package d;
  import a::*;
endpackage
module top;
  logic w;
endmodule
