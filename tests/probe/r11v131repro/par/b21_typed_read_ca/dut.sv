// § paramFoldParenSpan131
module top (output logic [31:0] o);
  parameter int P = (3 + 4);
  assign o = P;
endmodule
