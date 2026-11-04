// § classSpecPaNoFile152
class C #(int W=4);
  bit [W-1:0] x;
endclass
module top ();
  C#(8) c1 = new;
endmodule
