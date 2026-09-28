// § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2);
endclass
interface ifc;
  c #(8) h;
endinterface
program prg;
  c #(8, 3) h;
endprogram
module a04;
  c #(8, 9) h;
  if (1) begin : g
    c #(3) q;
  end
  ifc i();
  prg p();
endmodule
