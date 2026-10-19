// § modKwlessTypeParamDropped412
interface ifc #(type T = logic [3:0]);
  T d;
endinterface
module top #(localparam type L = logic [1:0]) (input L a, output L b);
  ifc i();
  assign b = a;
endmodule
