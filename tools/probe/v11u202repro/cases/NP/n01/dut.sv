// § modPkgGenericSpecNamedBare202
package p;
  class c #(int W = 1);
  endclass
  class b #(type T = int);
  endclass
endpackage
interface ifc;
  p::c #(8) h;
  p::b #(byte) k = new;
endinterface
program prg;
  p::c #(8) h;
endprogram
module n01;
  ifc i();
  prg g();
endmodule
