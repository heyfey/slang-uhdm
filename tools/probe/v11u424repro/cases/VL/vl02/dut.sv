// § defGenLpSelIdxThroughBase424
module top #(parameter logic [7:0] P = 8'hA5, parameter int K = 1) (output logic [3:0] o);
  for (genvar i = 0; i < 3; i++) begin : rof
    localparam A = P[(i)];
    localparam B = P[K + i];
    assign o[i] = A ^ B;
  end
endmodule
