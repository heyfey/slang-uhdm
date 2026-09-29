// § ifArrElemLitCaFresh225 (a plain interface-array port, no modport)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module m(bi pb[2], output logic o);
  assign pb[1].w = 1'b1;
  assign o = pb[1].w;
endmodule
module top(output logic o);
  bi b[2]();
  m u(.pb(b), .o(o));
endmodule
