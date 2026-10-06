// § pkgSelPsBoundColonsElab260 (an always_comb inside an if-generate block, the module parameter in the bound)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
endpackage
module m #(parameter int W = 8) (input logic [7:0] d, output logic [7:0] q);
  if (W > 4) begin : g
    always_comb begin
      q = d;
      q ^= cp::RC[1][W-1:0];
    end
  end else begin : h
    assign q = d;
  end
endmodule
module top;
  logic [7:0] d, q;
  m u (.d(d), .q(q));
endmodule
