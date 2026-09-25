// § classSpecPaNoFile152
class resource #(type T=int);
endclass
module sub #(parameter type R = resource#(longint)) ();
  R r;
endmodule
module top ();
  sub u();
endmodule
