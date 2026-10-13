// § ifaceTailDupGenChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
program prg (ifc.mp p);
  initial $display(p.sig);
endprogram
module top;
  ifc inst ();
  if (1) begin : g
    prg pi (.p(inst));
  end
endmodule
