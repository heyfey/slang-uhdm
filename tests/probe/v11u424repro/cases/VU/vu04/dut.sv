// § ifcUnitVarRefMintsNet424
int x1 = 1;
int x2 = 2;
interface ifc;
  initial $display("%0d %0d", x2, x1);
endinterface
module top; ifc u (); endmodule
