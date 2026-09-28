// § modSpecValueArgDefViewMultiArg202v § modSpecValueArgSpanAtName202
class c #(int W = 1, int V = 2, int U = 3);
endclass
program prg;
  c #(1, 2) h;
  c #(1, 2, 3) k = new;
endprogram
interface ifc;
  c #(5) h;
  c #(5, 6) k;
endinterface
module a02;
  prg p();
  ifc i();
  c #(7, 8, 9) m;
endmodule
