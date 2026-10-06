// § retTopRangeOwnPkg269 (the function called from the importer and from a module)
package up;
  parameter W = 12;
  parameter LS = W*8-1;
  function logic [LS:0] s2b(string str);
    $swrite(s2b, "%0s", str);
  endfunction
endpackage
package sp;
  import up::*;
  function int g(); logic [LS:0] b; b = s2b("x"); return b[3:0]; endfunction
endpackage
module top(output logic [3:0] o);
  assign o = up::s2b("ab");
endmodule
