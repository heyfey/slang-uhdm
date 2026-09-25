// § defaultFillOneConstant140
module dut #(parameter int W = 5) (input logic [1:0] s, output logic [7:0] o);
  localparam logic [7:0] A [4] = '{default: W + 1};
  assign o = A[s];
endmodule
