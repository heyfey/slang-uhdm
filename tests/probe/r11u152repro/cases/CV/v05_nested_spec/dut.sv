// § classSpecNestedAtName152
virtual class object#(type T=int);
endclass
class config_db#(type T=int);
endclass
module top ();
  config_db#(object#(longint)) misc2 = new;
endmodule
