// § ifaceElabInlineSuKeyword130
interface bus;
  struct packed { logic [3:0] a; } s = '0;
  struct packed {
    logic x;
  } t;
endinterface
module top;
  bus b();
endmodule
