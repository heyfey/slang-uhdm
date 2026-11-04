// § pkgSelPsBoundColonsElab260 (the top module's parameter in an initial block's compound assignment)
package cp;
  parameter logic [3:0][15:0] RC = {16'h1234, 16'h5678, 16'h9abc, 16'hdef0};
  parameter logic [1:0][3:0][15:0] R3 = '0;
endpackage
module top #(parameter int W = 4) (output logic [15:0] q);
  initial begin
    q = '0;
    q ^= cp::R3[0][1][W-1:0];
  end
endmodule
