// § sgnLitElabFreshIntTs266
module leaf #(parameter int P = 8'sh11) (output logic [31:0] o);
  assign o = P;
endmodule
module mid #(parameter int R = 8'sh22) (output logic [31:0] o, output logic [31:0] p);
  leaf l (.o(o));
  leaf #(.P(R)) m (.o(p));
endmodule
module dut (output logic [31:0] o, output logic [31:0] p);
  for (genvar k = 0; k < 1; k++) begin : g
    mid u (.o(o), .p(p));
  end
endmodule
