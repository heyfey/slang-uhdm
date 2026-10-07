// § pkgElabUnaryFoldOpSpan274
package pk;
  parameter int K = -2;
endpackage
module dut(output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    if (pk::K < 0) begin : n
      assign o[i] = 1'b1;
    end else begin : p
      assign o[i] = 1'b0;
    end
  end
  assign o[3:2] = pk::K;
endmodule
