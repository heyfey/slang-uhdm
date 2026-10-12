// § tpUseClassTargetAbstains291v
package pk; class c; int x; endclass endpackage
module child #(parameter type T = pk::c) (output int o);
  T h;
  initial begin h = new; o = h.x; end
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
