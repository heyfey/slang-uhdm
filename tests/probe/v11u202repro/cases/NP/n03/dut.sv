// § modPkgGenericSpecNamedBare202
package p;
  class c #(int W = 1);
  endclass
endpackage
module sub (input int x);
  p::c #(8) h;
endmodule
module n03;
  p::c #(8) h;
  p::c #() e;
  sub s(.x(1));
endmodule
