// § callArgVarSelStamp198
package pk; function automatic logic pf(logic x); return x; endfunction endpackage
module top (input logic [3:0] a [2][2], input logic [1:0][3:0] p, input logic [3:0] b, input logic [1:0][1:0] w [2], output logic y, output logic [3:0] y4, output logic [1:0] z [2], output logic [1:0][1:0] zz);
  function automatic logic f(logic x); return x; endfunction
  function automatic logic [3:0] g(logic [3:0] x); return x; endfunction
  function automatic logic f2(logic u, logic v); return u & v; endfunction
  wire wn = f(p[1][2]);
  assign y = wn;
endmodule
