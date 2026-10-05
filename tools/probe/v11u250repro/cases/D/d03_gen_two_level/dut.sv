// § pkgAliasOfKwBind250
// alias declarators in a generate block and a two-level instance
package p;
  typedef shortint s_t;
  typedef s_t al_t;
endpackage
module leaf(output shortint o);
  import p::*;
  al_t v; assign v = 16'd1; assign o = v;
endmodule
module top(output shortint o1, o2);
  import p::*;
  al_t v; assign v = 16'd2; assign o1 = v;
  if (1) begin : g
    al_t gv;
    assign gv = v;
    leaf l(.o(o2));
  end
endmodule
