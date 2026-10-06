// § sgnLitElabFreshIntTs266
module dut #(parameter int S = 3) (output logic [31:0] o);
  localparam int P = 8'sd3;
  case (S)
    1: begin : c1 assign o = P; end
    default: begin : cd
      for (genvar k = 0; k < 1; k++) begin : f assign o = P + k; end
    end
  endcase
endmodule
