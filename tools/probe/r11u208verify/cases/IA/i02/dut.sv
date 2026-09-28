// § ifaceArrPortElemViewNamedByArray200
interface pif;
  logic [3:0] d;
  logic v;
endinterface
module sub(pif p[3], output logic [3:0] y);
  assign y = p[0].d | p[2].d;
  assign p[1].v = 1'b0;
endmodule
module sub2(pif p[3], output logic [3:0] y);
  assign y = p[1].d;
endmodule
module top(output logic [3:0] y1, output logic [3:0] y2);
  pif pa[3]();
  sub s1(pa, y1);
  sub2 s2(.p(pa), .y(y2));
endmodule
