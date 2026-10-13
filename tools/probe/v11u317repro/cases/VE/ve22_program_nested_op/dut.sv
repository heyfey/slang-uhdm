// § modConnIdxNestedNames317
program pchild (input logic d);
  initial $display(d);
endprogram
module top (input logic [3:0] ck, input logic [1:0] k, input logic a, output logic o);
  pchild p (.d(ck[k[0]] | a));
  assign o = a;
endmodule
