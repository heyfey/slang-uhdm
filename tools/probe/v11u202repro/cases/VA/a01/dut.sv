// § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2);
endclass
class m #(int W = 1, type T = int);
endclass
interface ifc;
  c #(8) h;
endinterface
module a01;
  c #(8, 9) h;
  c #(.W(8)) k;
  m #(4) j;
  if (1) begin : g
    c #(3) q;
  end
  ifc i();
endmodule
