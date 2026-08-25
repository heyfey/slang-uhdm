// The SAME package imported at $unit AND inside a module AND inside a package.
package pv14;
  parameter int DUO = 33;
endpackage
package pv14b;
  import pv14::*;
  function automatic int fz(); return DUO; endfunction
endpackage
import pv14::*;
module top_v14;
  import pv14::*;
  int z;
  initial z = DUO + pv14b::fz();
endmodule
