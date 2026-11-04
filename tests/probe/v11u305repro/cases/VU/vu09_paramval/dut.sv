// § ifCaUnsizedRhsClonePerInst305
interface bif #(parameter logic [7:0] P = 8'h3)();
  logic sig;
  logic [7:0] arr[2];
  assign arr[0] = sig ? P : '0;
endinterface
module top;
  bif #(.P(8'h5)) b0();
  bif #(.P(8'h7)) b1();
endmodule
