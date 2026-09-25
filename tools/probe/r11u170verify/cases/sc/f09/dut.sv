// § sizeCastCaSignedSize158
module dut (output logic [7:0] p, output logic [3:0] q, output logic [5:0] r);
  localparam int V = -1;
  localparam shortint S = 5;
  localparam integer I = 6;
  assign p = 3'(V);
  assign q = 2'(S);
  assign r = 2'(I);
endmodule
