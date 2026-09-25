// § classSpecNestedAtName152
virtual class object#(type T=int);
endclass
class pair#(type A=int, type B=int);
endclass
module top ();
  pair#(object#(int), object#(byte)) p;
endmodule
