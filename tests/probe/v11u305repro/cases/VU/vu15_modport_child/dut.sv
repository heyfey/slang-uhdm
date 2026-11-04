// § ifCaPlainLhsNoVarBind305
interface bif();
  logic sig;
  logic [7:0] w;
  assign w = {8{sig}} | '0;
  modport mp (input w, output sig);
endinterface
module c(bif.mp p); assign p.sig = 1'b1; endmodule
module top;
  bif b0();
  bif b1();
  c c0(.p(b0.mp));
  c c1(.p(b1.mp));
endmodule
