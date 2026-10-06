// § sgnLitElabFreshIntTs266
module sub #(parameter int A = 8'sh01, parameter int unsigned B = 8'sh02, parameter integer C = 8'sh03, parameter shortint D = 8'sh04, parameter logic signed [7:0] E = 8'sh05) (output logic [31:0] o);
  assign o = A + B + C + D + E;
endmodule
module dut (output logic [31:0] o);
  sub u (.o(o));
endmodule
