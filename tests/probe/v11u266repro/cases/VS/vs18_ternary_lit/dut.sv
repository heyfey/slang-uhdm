// § sgnLitElabFreshIntTs266
module dut (output logic [31:0] o);
  localparam int P = 4'sh7;
  localparam int Q = 1 ? P : 4'sh2;
  assign o = Q;
endmodule
