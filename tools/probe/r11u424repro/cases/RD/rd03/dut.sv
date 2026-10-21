// § defGenLpSelIdxThroughBase424
module top #(parameter int P [3:0] = '{5,4,1,0}, parameter int Q [7:0] = '{8{1}}) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 2; i++) begin : rof
    localparam A = P[i+1] + Q[i*2];
    assign o[i] = A[0];
  end
endmodule
