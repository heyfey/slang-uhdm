// § ternSgnLitFreshIntTs284
module dut(output logic [31:0] o);
  localparam bit C = 1;
  localparam int T = C ? 4'sd3 : 4'sd1;
  logic [T:0] v;
  assign v = '1;
  assign o = v;
endmodule
