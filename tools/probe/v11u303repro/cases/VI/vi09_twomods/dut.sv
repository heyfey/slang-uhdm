// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endinterface
module m1; bus_t2 #(.P(0)) b(); endmodule
module m2; bus_t2 #(.P(0)) b(); endmodule
module top; m1 u1(); m2 u2(); endmodule
