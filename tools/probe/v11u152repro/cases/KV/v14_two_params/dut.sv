// § classSpecPaNoFile152
class C #(type T=int, type U=bit);
  T x; U y;
endclass
module top ();
  C#(byte, logic) c1 = new;
endmodule
