// § ternSgnLitFreshIntTs284
module sub #(parameter bit C = 1'b0) (output logic [31:0] o);
  localparam int T = C ? 1'sb1 : 1'b0;
  assign o = T;
endmodule
module dut(output logic [31:0] o1, o2);
  sub #(.C(1'b1)) u1(.o(o1));
  sub u2(.o(o2));
endmodule
