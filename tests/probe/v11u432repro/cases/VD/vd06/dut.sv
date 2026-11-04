// § unitParamSizeDimWide432
parameter D = 5;
interface ifc;
  logic [3:0] iv [D];
endinterface
program pr;
  logic [3:0] prv [D];
endprogram
module m(input clk);
  ifc i();
endmodule
