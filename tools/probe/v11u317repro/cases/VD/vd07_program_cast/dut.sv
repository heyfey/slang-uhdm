// § selIdxCastTsNamedBySel317
program pchild (input logic d);
  initial $display(d);
endprogram
module top (input logic [3:0] ck, input logic [2:0] s, output logic o);
  pchild p (.d(ck[2'(s)]));
  assign o = ck[0];
endmodule
