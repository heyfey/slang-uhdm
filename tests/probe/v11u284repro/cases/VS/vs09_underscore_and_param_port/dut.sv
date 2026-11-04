// § ternSgnLitFreshIntTs284
module dut #(parameter bit C = 1'b1, parameter int T = C ? 8'sb1111_0000 : 8'sb0) (output logic [31:0] o);
  assign o = T;
endmodule
