// § modConnSelWholeLeafElab319
program prog (input logic d);
endprogram
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  prog p (.d(ck[1+s]));
  assign o = a;
endmodule
