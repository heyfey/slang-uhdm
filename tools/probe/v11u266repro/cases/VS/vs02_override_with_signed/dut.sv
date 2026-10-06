// § sgnLitElabFreshIntTs266
module sub #(parameter int P = 5) (output logic [31:0] o);
  assign o = P;
endmodule
module dut (output logic [31:0] o);
  sub #(.P(8'sh10)) u (.o(o));
endmodule
