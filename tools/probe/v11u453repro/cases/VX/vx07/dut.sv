// § pkgExplicitImpParamReExport453
package a;
  function automatic int fa(); return 1; endfunction
  parameter int PA = 1;
endpackage
package b;
  import a::fa;
  import a::PA;
endpackage
module top;
  import b::*;
endmodule
