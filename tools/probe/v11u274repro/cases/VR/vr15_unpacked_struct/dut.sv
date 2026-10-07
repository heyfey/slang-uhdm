// § elabMemberReadCopyChain274
package pk;
  typedef struct { int a; int b; } in_t;
  typedef struct { in_t u; int d; } c_t;
endpackage
module kid #(parameter pk::c_t P = '{u: '{a: 1, b: 2}, d: 3}) (output int o);
  assign o = P.u.a + P.d;
endmodule
module dut(output int o, output int o2);
  kid k0 (.o(o));
  kid #(.P('{u: '{a: 5, b: 6}, d: 7})) k1 (.o(o2));
endmodule
