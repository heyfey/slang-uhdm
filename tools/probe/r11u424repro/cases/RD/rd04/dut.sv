// § defGenLpSelIdxThroughBase424
module top #(parameter int P [3:0] = '{5,4,1,0}) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 2; i++) begin : rof
    localparam A = $clog2(P[i+1]);
    localparam B = (P[(i)] > 1) ? P[i+2] : 0;
    assign o[i] = A[0] ^ B[0];
  end
endmodule
