// § paramFoldParenSpan131
module sub #(parameter N = 4) (output logic [31:0] o);
  localparam L = ($clog2(N) + 1);
  assign o = L;
endmodule
module top (output logic [31:0] o);
  sub #(.N(9)) u(.o(o));
endmodule
