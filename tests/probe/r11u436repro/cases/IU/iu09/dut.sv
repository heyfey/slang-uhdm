// § cgArrayElemUnsupportedTs436
module top #(int N = 4) (input clk, input a);
covergroup cg();
  coverpoint a;
endgroup
cg cgs[N];
endmodule
