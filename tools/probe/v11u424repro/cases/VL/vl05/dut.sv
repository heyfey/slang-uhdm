// § defGenLpSelIdxThroughBase424
module top #(parameter logic [7:0] P = 8'hA5) (output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : rof
    for (genvar j = 0; j < 2; j++) begin : inner
      localparam A = P[i*2 + j];
      assign o[i*2+j] = A;
    end
  end
endmodule
