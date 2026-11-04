// § sgnLitElabFreshIntTs266
module dut #(parameter int S = 1) (output logic [31:0] o);
  localparam int P = 8'sd3;
  if (S == 1) begin : a
    assign o = P;
  end else begin : b
    case (S) 2: begin : c assign o = P + 1; end default: begin : d assign o = 0; end endcase
  end
endmodule
