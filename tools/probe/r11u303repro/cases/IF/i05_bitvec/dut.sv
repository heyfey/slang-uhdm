// § ifCaTernFillArmKept303
interface bus_t2 #(parameter bit P = 0)();
  logic [1:0] sig;
  logic [7:0] vec;
  assign vec[0] = (P) ? sig[0] ^ sig[1] : '0;
endinterface
module top;
  bus_t2 bi();
endmodule
