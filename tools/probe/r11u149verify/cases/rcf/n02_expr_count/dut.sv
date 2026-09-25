// § replCountFoldFile140
module dut #(parameter int N = 2) (input logic [1:0] s, output logic [3:0] o);
  localparam logic [3:0] A [N+1] = '{(N+1){4'h3}};
  assign o = A[s];
endmodule
