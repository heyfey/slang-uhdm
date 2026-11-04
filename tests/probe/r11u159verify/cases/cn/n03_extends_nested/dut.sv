// § classSpecNestedAtName152
virtual class object#(type T=int);
endclass
class base#(type T=int);
endclass
class D extends base#(object#(shortint));
endclass
module top ();
  D d = new;
endmodule
