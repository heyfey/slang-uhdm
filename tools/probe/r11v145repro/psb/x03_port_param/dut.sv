// § psBoundBareRefByBase145
module dut #(parameter int H = 7, parameter int L = 2) (input logic [15:0] a, output logic [5:0] o);
  assign o = a[H:L];
endmodule
