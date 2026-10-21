// § defGenLpSelIdxThroughBase424
module top #(parameter int N = 3, parameter int P [3:0] = '{5,4,1,0}) (output logic [3:0] o);
  if (N > 1) begin : g
    localparam A = P[N-1];
    assign o = A;
  end
endmodule
