// § genHopFoldSelName198: a one-hop fold in a select that is a call argument, a concatenation element, a ternary arm and a cast operand (the cast: v11u198's residue 4)
module top #(parameter int N = 2) (input logic c, input logic [15:0] a, output logic [3:0] y [4], output logic [1:0] z [4], output logic u [4], output logic [2:0] v [4]);
  function automatic logic [3:0] f(input logic x); return {3'b0, x}; endfunction
  for (genvar i = 0; i < 4; i++) begin : g
    localparam int unsigned L = i*3;
    if (N > 1) begin : h
      assign y[i] = f(a[L]);
      assign z[i] = {a[L], a[L+1]};
      assign u[i] = c ? a[L] : a[0];
      assign v[i] = 3'(a[L]);
    end
  end
endmodule
