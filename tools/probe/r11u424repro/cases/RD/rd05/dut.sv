// § defGenLpSelIdxThroughBase424 (control: bare indices)
module top #(parameter int P [3:0] = '{5,4,1,0}) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 2; i++) begin : rof
    localparam A = P[i];
    assign o[i] = A[0];
  end
endmodule
