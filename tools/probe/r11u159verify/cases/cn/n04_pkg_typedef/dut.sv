// § classSpecNestedAtName152
package pk;
  virtual class object#(type T=int);
  endclass
  class config_db#(type T=int);
  endclass
  typedef config_db#(object#(longint)) cfg_t;
endpackage
module top ();
  pk::cfg_t m;
endmodule
