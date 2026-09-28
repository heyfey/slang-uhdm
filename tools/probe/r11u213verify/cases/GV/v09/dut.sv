// § genScopeClassVarListed206 (an interface's generate scope and a program's)
class c; int x; endclass
interface ifc ();
  if (1) begin : g
    c q;
  end
endinterface
program prg ();
  if (1) begin : g
    c r;
  end
endprogram
module v09 ();
  ifc i ();
  prg p ();
endmodule
