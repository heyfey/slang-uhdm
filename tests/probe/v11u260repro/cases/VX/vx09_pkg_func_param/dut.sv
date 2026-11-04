// § pkgSelPsBoundColonsElab260 (a package function, a package parameter in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
package q;
  parameter int PW = 8;
  function automatic logic [15:0] f(logic [15:0] x);
    logic [15:0] r;
    r = x;
    r ^= cp::RC[0][PW-1:0];
    return r;
  endfunction
endpackage
module top (input logic [15:0] d, output logic [15:0] o);
  assign o = q::f(d);
endmodule
