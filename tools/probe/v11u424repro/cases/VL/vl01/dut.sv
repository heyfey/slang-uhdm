// § defGenLpSelIdxThroughBase424
module top #(parameter logic [7:0] P = 8'hA5) (output logic [3:0] o);
  for (genvar i = 0; i < 3; i++) begin : rof
    localparam A = P[i*2];
    assign o[i] = A;
  end
endmodule
