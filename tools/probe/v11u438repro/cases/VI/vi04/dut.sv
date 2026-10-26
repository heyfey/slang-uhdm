// § ifNdaUnsizedFreshLhs438
interface ifc(input [15:0] b);
  wire w = b['h3];
  modport mp(input w);
endinterface
module sub(ifc.mp p, output y);
  assign y = p.w;
endmodule
module top(input [15:0] b, output y);
  ifc i0(b);
  sub u(.p(i0), .y(y));
endmodule
