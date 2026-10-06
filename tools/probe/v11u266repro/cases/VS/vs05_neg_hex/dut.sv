// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o, output logic [31:0] p);
  localparam int P = 8'sh80;
  localparam int signed Q = 4'sd7;
  assign o = P;
  assign p = Q;
endmodule
