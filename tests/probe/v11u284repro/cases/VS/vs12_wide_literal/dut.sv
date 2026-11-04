// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o);
  localparam bit C = 1;
  localparam int T = C ? 40'shF_0000_0001 : 40'sh0;
  assign o = T;
endmodule
