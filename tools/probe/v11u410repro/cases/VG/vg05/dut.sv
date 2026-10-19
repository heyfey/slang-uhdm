// § genLpUntypedDefNoTs410
module top #(parameter W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
  case (W)
    4: begin : g
      localparam int T = 3;
      localparam U = T + 1;
      localparam logic [7:0] V = 5;
      assign y = a + U[W-1:0] + V[W-1:0];
    end
    default: begin : d assign y = a; end
  endcase
endmodule
