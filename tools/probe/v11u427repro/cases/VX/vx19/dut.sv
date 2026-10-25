// § xzOvLitKeepsText427
interface ifc #(parameter P = 0);
  logic [7:0] s;
  assign s = P;
endinterface
module top;
  ifc #(.P(4'b1x)) u();
endmodule
