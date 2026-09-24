// § ifaceElabInlineSuKeyword130
interface bus;
  struct packed { logic [3:0] a; logic [3:0] b; } s1;
  struct packed { logic x; logic y; } s2;
endinterface
module top;
  bus b1();
  bus b2();
endmodule
