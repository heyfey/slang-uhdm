// § nestedDefPortsNeedShell297
interface inner_if; logic d; endinterface
interface outer_if; inner_if n(); logic e; endinterface
module dut(output logic o);
  outer_if x();
  assign x.n.d = 1'b0;
  assign x.e = x.n.d;
  assign o = x.e;
endmodule
