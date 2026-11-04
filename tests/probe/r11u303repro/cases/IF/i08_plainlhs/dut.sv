// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] w;
  assign w = (P) ? {8{sig}} : '0;
endinterface
module top;
  bus_t2 bi();
endmodule
