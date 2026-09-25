// § defaultFillOneConstant140
module dut (input logic [1:0] s, output logic [3:0] o);
  parameter logic [3:0] A [0:3] = '{default: 4'h9};
  assign o = A[s];
endmodule
