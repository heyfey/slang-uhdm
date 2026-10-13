// § modConnIdxNestedNames317
program prg (input logic d);
endprogram
module top (input logic [3:0] ck, input logic [1:0] k, input logic [2:0] s, input logic [1:0][1:0] m, input logic a, output logic o);
  prg p (.d(ck[k[0]] | a));
  assign o = a;
endmodule
