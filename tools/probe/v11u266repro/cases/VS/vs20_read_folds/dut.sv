// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o, output logic [7:0] p, output logic [31:0] r);
  localparam int P = 8'sh7F;
  localparam logic [7:0] Q = P;
  localparam int unsigned U = P + 1;
  assign o = $bits(P);
  assign p = Q;
  assign r = U;
endmodule
