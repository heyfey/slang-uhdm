// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic sig;
  logic [7:0] vec;
  assign vec[0] = (P) ? sig : '0;
endinterface
module top;
  bus_t2 bi();
endmodule
