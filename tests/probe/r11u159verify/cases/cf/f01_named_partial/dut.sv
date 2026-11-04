// § classSpecPaNoFile152
class resource #(type T=int, type U=int);
endclass
module top ();
  resource#(.U(byte)) r1;
endmodule
