// § ifaceTailDupArrayChild309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
program prg (ifc.mp p);
  initial $display(p.sig);
endprogram
module top;
  ifc inst ();
  prg pa [2] (.p(inst));
endmodule
