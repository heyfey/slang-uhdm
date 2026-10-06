// § pkgSelIdxRefColons254 (a net declaration assignment, a variable initializer and a parameter default: not assignment expressions)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
module top #(parameter int W = 2, parameter logic [7:0] D = cp::R3[W-1][0]) (output logic [7:0] o, output logic [7:0] p);
  wire [7:0] w = cp::R3[W-1][0];
  logic [7:0] v = cp::R3[W-1][1];
  assign o = w ^ v;
  assign p = D;
endmodule
