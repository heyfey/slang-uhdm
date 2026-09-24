// § suSigningNotInSpan130
interface bus;
  struct packed signed { logic [3:0] a; } s;
endinterface
module top;
  bus b();
endmodule
