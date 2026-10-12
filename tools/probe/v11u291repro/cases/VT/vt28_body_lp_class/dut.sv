// § tpUseClassTargetAbstains291v
package pk; class c; int x; endclass endpackage
module child (output int o);
  localparam type T = pk::c;
  T h;
  initial begin h = new; o = h.x; end
endmodule
module dut (output int o);
  child u (.o(o));
endmodule
