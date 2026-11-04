// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 1)();
  logic sig;
  logic [7:0] vec;
  assign vec[3:0] = (P) ? '1 : {4{sig}};
endinterface
module top;
  bus_t2 bi();
endmodule
