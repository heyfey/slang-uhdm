module dut #(parameter int W = 3, parameter type idx_t = logic [W-1:0]) (input logic [1:0] sel, input logic [7:0] v, output logic [7:0] y);
  if (W > 1) begin : g1
    if (W < 8) begin : g2
      always_comb begin
        case (sel)
          2'd0: y = idx_t'(v[2:0] + 3'd1);
          2'd1: y = idx_t'({v[0], v[1]});
          default: y = idx_t'(v);
        endcase
      end
    end
  end
endmodule
