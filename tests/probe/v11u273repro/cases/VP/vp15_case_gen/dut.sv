// § paramValRhsSharesParamConst273
module dut #(parameter int S = 1) (output logic [31:0] o2 [2]);
  case (S)
    1: begin : c1
      localparam int unsigned K = 44;
      assign o2[0] = K;
    end
    default: begin : cd
      assign o2[0] = '0;
    end
  endcase
  assign o2[1] = S;
endmodule
