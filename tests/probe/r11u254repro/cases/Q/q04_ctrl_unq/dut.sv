// § pkgSelIdxRefColons254 (control: the same selects through a wildcard import and on a local net)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (input logic [3:0][7:0] n, output logic [3:0] o, output logic [3:0] p);
  import cp::*;
  assign o = RC[0][W-1:0];
  assign p = n[0][W-1:0];
endmodule
