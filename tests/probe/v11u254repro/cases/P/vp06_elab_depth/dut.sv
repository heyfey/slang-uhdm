// § pkgSelIdxRefColons254 (the select in a child instance two levels down, and in an elaborated generate if scope)
package cp;
  parameter logic [3:0][7:0] RC = {8'h11, 8'h22, 8'h33, 8'h44};
  parameter logic [1:0][3:0][7:0] R3 = {8'h1, 8'h2, 8'h3, 8'h4, 8'h5, 8'h6, 8'h7, 8'h8};
  parameter int IDX = 1;
  function automatic int f(int x); return x - 1; endfunction
endpackage
module leaf #(parameter int W = 2) (output logic [7:0] o);
  assign o = cp::R3[W-1][1];
endmodule
module mid #(parameter int W = 2) (output logic [7:0] o, output logic [7:0] p);
  leaf #(.W(W)) u (.o(o));
  if (W == 2) begin : gi
    assign p = cp::R3[W-2][W];
  end else begin : ge
    assign p = '0;
  end
endmodule
module top (output logic [7:0] o, output logic [7:0] p);
  mid #(.W(2)) m (.o(o), .p(p));
endmodule
