// § defGenLpSelIdxThroughBase424
module top #(parameter int P [4] = '{1,2,3,4}) (output int o [3]);
  for (genvar i = 0; i < 3; i++) begin : rof
    localparam int A = P[i+1];
    assign o[i] = A;
  end
endmodule
