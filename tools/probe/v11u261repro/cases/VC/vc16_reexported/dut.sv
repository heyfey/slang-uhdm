// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
package cq;
  import cp::*;
  export cp::*;
  parameter int Z = 1;
endpackage
module top (input logic [3:0] a, output logic [3:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    assign o[k] = a ^ cp::RC[k][3:0] ^ cq::Z;
  end
endmodule
