// § tpUseClassTargetAbstains291v
package pk; class c; int x; endclass class d; int y; endclass endpackage
module child #(parameter type T = pk::c) (output int o);
  T h;
  initial begin h = new; o = 1; end
endmodule
module dut (output int o);
  child #(.T(pk::d)) u (.o(o));
endmodule
