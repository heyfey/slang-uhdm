module m #(parameter int K = 1) (input logic [15:0] rd [2], input logic [3:0] o, output logic [3:0] y);
  case (K)
    1: begin : c1
      assign y = rd[1][o +: 4];
    end
    default: begin : cd
      assign y = rd[0][o +: 4];
    end
  endcase
endmodule
