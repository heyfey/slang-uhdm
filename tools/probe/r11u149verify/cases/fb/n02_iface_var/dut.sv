// § foldedBoundTsRefUnstored144
interface ifc #(parameter int P = 3);
  logic [P:0] v;
endinterface
module dut(input logic [3:0] a, output logic [3:0] y);
  ifc #(.P(3)) u();
  assign u.v = a;
  assign y = u.v;
endmodule
