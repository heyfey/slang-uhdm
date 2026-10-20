// § stdRandomizeFuncCall413
interface ifc;
  bit [7:0] a;
  bit ok;
  initial ok = randomize(a);
endinterface
module top;
  ifc u();
endmodule
