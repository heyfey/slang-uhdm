// § ifaceElabInlineSuKeyword130
interface bus;
  union packed { logic [3:0] a; logic [3:0] b; } u;
  struct packed signed { logic [1:0] x; } s;
endinterface
module sub(bus b);
endmodule
module top;
  bus b0();
  sub u(.b(b0));
endmodule
