// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? {2{sig}} : '0;
endinterface
module m1 #(parameter bit Q = 0); bus_t2 #(.P(Q)) b(); endmodule
module top; m1 #(.Q(0)) u1(); m1 #(.Q(1)) u2(); endmodule
