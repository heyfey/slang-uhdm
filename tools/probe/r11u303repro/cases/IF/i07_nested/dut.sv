// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0, parameter bit Q = 1)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[1] = P ? {8{sig}} : (Q ? '0 : {8{~sig}});
endinterface
module top;
  bus_t2 bi();
endmodule
