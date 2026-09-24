module top #(parameter int unsigned W = 2, parameter type idx_t = logic [W-1:0]) (input logic a, b, s, output logic [1:0] y, output logic [1:0] z);
  case (W)
    2: begin : g
      assign y = s ? idx_t'(a) : idx_t'(b);
    end
  endcase
  assign z = '0;
endmodule
