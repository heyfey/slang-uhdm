// § caReduceOpKindGate276
module dut #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, m, output logic o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign o[i] = (P[i] & n[i]) ^ m[i];
  end
endmodule
