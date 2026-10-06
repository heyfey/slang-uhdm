// § sgnLitElabFreshIntTs266
module sub #(parameter int P = 8'sh7F) (output logic [31:0] o);
  assign o = P;
endmodule
module dut (output logic [31:0] o, output logic [31:0] p, output logic [31:0] r);
  localparam int Q = 4;
  sub #(.P(8'sh10)) u (.o(o));
  sub #(-3) v (.o(p));
  sub #(.P(Q)) w (.o(r));
endmodule
