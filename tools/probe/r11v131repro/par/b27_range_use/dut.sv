// § paramFoldParenSpan131
module sub #(parameter int W = (2 * 4)) (output logic [W-1:0] o);
  assign o = '0;
endmodule
module top (output logic [7:0] o);
  sub u(.o(o));
endmodule
