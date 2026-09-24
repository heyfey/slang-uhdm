module top (output logic [7:0] o);
  localparam logic [63:0] M = 64'hDEADBEEF_12345678;
  assign o = M[7:0];
endmodule
