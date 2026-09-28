// § genHopFoldSelName198 § tpArrBoundAtLeftOperand196: a hop fold as a select index beside type-parameter arrays whose bounds fold from the hop localparam in a nested generate scope
module top #(parameter int N = 2, parameter type T = logic [1:0]) (input logic [15:0] a, output logic [1:0] y [4], output logic z [4]);
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i + 1;
    if (N > 1) begin : h
      T [L*2-1:0] v;
      T [L+N-1:0] u;
      assign v = a;
      assign u = a;
      assign y[i] = v[L-1];
      assign z[i] = a[L];
    end
  end
endmodule
