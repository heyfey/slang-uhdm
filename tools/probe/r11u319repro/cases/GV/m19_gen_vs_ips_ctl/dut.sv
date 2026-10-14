// § defGenVarSelIdxExpr319
module c(input logic [3:0] a, output logic [3:0] z); assign z = a; endmodule
module m(input logic [31:0] rd [5], input logic [4:0] o, input logic [2:0] s, output logic [3:0] y [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    c u(.a(rd[s+1][o -: 4]), .z(y[i]));
  end
endmodule
