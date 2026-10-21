// § ifcUnitVarRefMintsNet424 (control: the module road, pass 418)
string label = "X";
module m;
  initial $display("%s", label);
endmodule
module top;
  m u ();
endmodule
