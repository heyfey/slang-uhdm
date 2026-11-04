// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (input logic [3:0] a, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] x);
    return x ^ cp::RC[2][W-1:0];
  endfunction
  assign o = f(a);
endmodule
