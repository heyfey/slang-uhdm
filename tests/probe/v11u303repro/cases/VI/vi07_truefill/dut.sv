// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = (P) ? '0 : {8{sig}};
endinterface
module top;
  bus_t2 #(.P(1)) b0();
endmodule
