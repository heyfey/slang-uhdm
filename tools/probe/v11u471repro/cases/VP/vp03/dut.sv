// § procAsgRhsPkgFoldTs471
// module function and automatic task bodies, return of the parameter
package a;
  parameter logic [5:0] PA = 6'd33;
endpackage
module top(output logic [5:0] y, output logic [5:0] z);
  import a::*;
  function automatic logic [5:0] f();
    logic [5:0] r;
    r = PA;
    return PA;
  endfunction
  task automatic t(output logic [5:0] o);
    o = PA;
  endtask
  always_comb y = f();
  initial t(z);
endmodule
