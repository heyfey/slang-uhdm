// § pkgSelIdxRefColons254 (nonblocking, compound and blocking assignments in always_ff and always_comb, two and three levels)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
module top #(parameter int W = 2) (input logic clk, output logic [7:0] o, output logic [7:0] p, output logic [3:0] q);
  always_ff @(posedge clk) o <= cp::R3[W-1][0];
  always_ff @(posedge clk) begin p <= 8'h0; p |= cp::R3[0][W-1]; end
  always_comb q = cp::R3[1][W][W+1:W-2];
endmodule
