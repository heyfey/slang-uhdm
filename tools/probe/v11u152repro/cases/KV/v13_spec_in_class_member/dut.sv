// § classSpecPaNoFile152
class C #(type T=int);
  T x;
endclass
class H;
  C#(shortint) m = new;
endclass
module top ();
  H h = new;
endmodule
