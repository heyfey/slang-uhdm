module dut #(parameter int W = 2, parameter type idx_t = logic [W-1:0]) (input logic s, input logic [3:0] v, output logic [7:0] y);
  case (W)
    2: begin : c2
      assign y = s ? idx_t'({1'b1, v[0]}) : idx_t'(v[1:0]);
    end
    default: begin : cd
      assign y = '0;
    end
  endcase
endmodule
