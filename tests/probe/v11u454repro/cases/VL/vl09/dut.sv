// § pkgLateTsTransitiveImport454
package u;
  function automatic void f(ref int addr[]);
    foreach (addr[i]) addr[i] = 0;
  endfunction
endpackage
package mid;
  import u::*;
  int z;
endpackage
module top(output logic [7:0] addr);
  import mid::*;
  assign addr = 0;
endmodule
