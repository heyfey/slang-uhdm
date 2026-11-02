// § procAsgRhsPkgFoldTs471
// interface function and task assigning an imported parameter, called from a module
package a;
  parameter logic [3:0] PA = 4'd9;
endpackage
interface ifc;
  import a::*;
  logic [3:0] v;
  function automatic logic [3:0] get();
    logic [3:0] r;
    r = PA;
    return r;
  endfunction
  initial v = PA;
endinterface
module top(output logic [3:0] y);
  ifc u();
  always_comb y = u.get();
endmodule
