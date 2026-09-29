// § fixedOuterAssocInnerReg223 — leading-fixed arrays whose first unsized dimension is associative, in an interface, a generate block and a module, keyed by byte, string and int
interface bus_i;
  logic [3:0] ib [3][byte];
endinterface
module top;
  bus_i u_b();
  int ms [2][3][string];
  if (1) begin : g
    shortint gi [1:0][int];
  end
endmodule
