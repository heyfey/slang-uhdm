// § pkgQualSelChainOwnName261
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top (input logic [3:0] a, output logic [3:0] o);
  if (cp::RC[0][4:3] != 0) begin : g
    assign o = a ^ cp::RC[0][3:0];
  end else begin : h
    assign o = a;
  end
endmodule
