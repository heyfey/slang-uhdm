// § defGenSysInIdxLeaf319
program prog (input logic d);
endprogram
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  if (1) begin : g
    prog p (.d(ck[$signed(s)] | a));
  end
  assign o = a;
endmodule
