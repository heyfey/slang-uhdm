// § ifaceArrSliceElemName309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
program prg (ifc.mp p);
  initial $display(p.sig);
endprogram
module top;
  ifc arr [2] ();
  prg pa [2] (.p(arr));
endmodule
