// § psBoundBareRefByBase145
module dut #(parameter int L = 4) (input logic [31:0] a, output logic [3:0] o);
  assign o = a[L+3:L];
endmodule
