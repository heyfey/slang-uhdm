// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o, p);
  localparam bit C = 1;
  localparam int T = C ? 3'sb111 : 3'sb000;
  localparam int U = 3'sb111;
  assign o = T;
  assign p = U;
endmodule
