// § pkgSelPsBoundColonsElab260 (the module instantiated inside a for-generate with a genvar-derived override)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module m #(parameter int W = 8) (output logic [15:0] q, output logic [15:0] r);
  always_comb q = 16'(cp::RC[2][W-1:0]);
  always_comb begin
    r = '0;
    r ^= cp::RC[3][W-1:0];
  end
endmodule
module top;
  logic [15:0] q [2]; logic [15:0] r [2];
  for (genvar i = 0; i < 2; i++) begin : g
    m #(.W(4 + 4*i)) u (.q(q[i]), .r(r[i]));
  end
endmodule
