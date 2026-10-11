// § ternSgnLitFreshIntTs284
module sub #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = C ? 1'sb0 : 1'sb1;
  assign o = T;
endmodule
module dut(output logic [31:0] o, output logic [31:0] o2);
  sub u1 (.o(o));
  sub #(.C(1'b1)) u2 (.o(o2));
endmodule
