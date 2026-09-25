// § sizeCastCaSignedSize158
module dut #(parameter int V = 7, parameter int N = -1) (output logic [3:0] p, output logic [7:0] r);
  assign p = 2'(V);
  assign r = 3'(N);
endmodule
