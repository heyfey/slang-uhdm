// § importEnumCloneHomeInst469
// an enum parameter read by an importer function and a module
package a;
  typedef enum int {A0, A1} k_t;
  parameter k_t PK = A1;
endpackage
package b;
  import a::*;
  function automatic int g(); return int'(PK); endfunction
endpackage
module top;
  import b::*;
  int y;
  initial y = g();
endmodule
