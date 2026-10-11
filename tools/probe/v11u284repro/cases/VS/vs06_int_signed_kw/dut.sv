// § ternSgnLitFreshIntTs284
module dut #(parameter int W = 3) (output logic [31:0] o);
  localparam int signed T = (W > 2) ? 8'Sh80 : 8'sh7F;
  assign o = T;
endmodule
