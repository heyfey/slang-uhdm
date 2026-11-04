// § pkgSelPsBoundColonsElab260 (a class specialization's parameter in the bound, beside a module parameter)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  class C #(int W = 4);
  endclass
endpackage
module m #(parameter int W = 8) (output logic [15:0] q, output logic [15:0] r);
  always_comb begin
    q = '0;
    q ^= cp::RC[0][cp::C#(6)::W-1:0];
  end
  always_comb begin
    r = '0;
    r ^= cp::RC[1][W-1:0];
  end
endmodule
module top;
  logic [15:0] q, r;
  m u (.q(q), .r(r));
endmodule
