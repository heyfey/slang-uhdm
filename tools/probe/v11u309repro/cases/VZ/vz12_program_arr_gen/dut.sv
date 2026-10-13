// § defGenModArraySizeRange309
interface ifc;
  logic [7:0] sig;
  modport mp (input sig);
endinterface
program prg (ifc.mp p);
  initial $display(p.sig);
endprogram
module top;
  if (1) begin : g
    ifc finst ();
    prg pa [2] (.p(finst));
  end
endmodule
