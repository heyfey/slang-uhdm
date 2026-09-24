// § paramFoldParenSpan131
module top (output logic [7:0] o);
  parameter P = (3 + 4);
  assign o = P;
endmodule
