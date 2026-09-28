// § tpCastUseBindsDefDefault206
module e08 #(parameter int N = 2, parameter int W = 2, parameter type t = logic [W-1:0]) (input logic [3:0] r, output t o);
  t [2**N-2:0] x;
  for (genvar lv = 0; unsigned'(lv) < N; lv++) begin : gl
    for (genvar l = 0; l < 2**lv; l++) begin : g
      localparam int unsigned I0 = 2**lv-1+l;
      if (unsigned'(lv) == N-1) begin : f
        assign x[I0] = t'(r[l]);
      end else begin : o
        assign x[I0] = r[l] ? t'({1'b1, x[I0+1][0:0]}) : t'({1'b0, x[I0+2][0:0]});
      end
    end
  end
  assign o = x[0];
endmodule
