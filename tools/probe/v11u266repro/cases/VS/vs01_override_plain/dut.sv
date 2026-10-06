// § sgnLitElabFreshIntTs266
module sub #(parameter int P = 8'sh7F) (output logic [31:0] o);
  assign o = P;
endmodule
module dut (output logic [31:0] o, output logic [31:0] p);
  sub #(.P(5)) u (.o(o));
  sub v (.o(p));
endmodule
