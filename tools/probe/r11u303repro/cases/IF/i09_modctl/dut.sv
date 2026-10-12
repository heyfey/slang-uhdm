// § ifCaTernFillArmKept303
module m2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endmodule
module top;
  m2 #(.P(0)) bi();
endmodule
