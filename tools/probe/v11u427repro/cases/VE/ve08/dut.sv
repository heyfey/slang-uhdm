// § typedLitElabAdjustLogic427
interface ifc #(parameter logic [7:0] P = 4'hA);
  logic [7:0] s;
  assign s = P;
endinterface
module top;
  ifc u();
endmodule
