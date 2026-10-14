// § modConnVarSelWholeNames319
program prg (input logic d);
  initial $display(d);
endprogram
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  prg p (.d(m[s][1]));
  assign o = a;
endmodule
