// § sgnLitElabFreshIntTs266
module sub #(parameter int P = 8'sh0F, parameter int Q = P + 1) (output logic [31:0] o);
  assign o = Q;
endmodule
module dut (output logic [31:0] o);
  sub u (.o(o));
endmodule
