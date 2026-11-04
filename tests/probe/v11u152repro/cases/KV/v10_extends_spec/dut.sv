// § classSpecPaNoFile152
class C #(type T=int);
  T x;
endclass
class D extends C#(byte);
endclass
module top ();
  D d = new;
endmodule
