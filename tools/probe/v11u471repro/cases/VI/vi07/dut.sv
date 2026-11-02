// § pkgInitImpReadFolds471
// read in a package function body and in a package variable initializer
package a;
  parameter int PA = 7;
endpackage
package b;
  import a::*;
  int pv = PA;
  function automatic int g(); return PA + 1; endfunction
  localparam int LG = 1;
endpackage
module top(output int y);
  import b::*;
  assign y = LG;
endmodule
