// § sgnLitElabFreshIntTs266
module sub #(parameter int P = 12'shFFF) (output logic [63:0] o);
  assign o = P;
endmodule
module dut (output logic [63:0] o, output logic [63:0] o2);
  sub u (.o(o));
  sub #(.P(12'sh7)) u2 (.o(o2));
endmodule
