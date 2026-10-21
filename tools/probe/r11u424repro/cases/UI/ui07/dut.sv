// § ifcUnitVarRefMintsNet424
string label = "X";
interface ifc;
  logic q;
  initial $display("%s", label);
  modport mp(input q);
endinterface
module sub(ifc.mp p);
  initial $display("%b", p.q);
endmodule
module top;
  ifc u ();
  sub s(.p(u));
endmodule
