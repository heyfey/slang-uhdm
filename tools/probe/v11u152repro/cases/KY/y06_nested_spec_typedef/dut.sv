// § classSpecNestedAtName152
virtual class object#(type T=int);
endclass
class config_db#(type T=int);
endclass
module top ();
  typedef config_db#(object#(longint)) cfg_t;
  cfg_t misc2 = new;
endmodule
