// § dottedCallHpSpansInvocation294
// hierarchical user calls nested in each other and an argument call
module sub; function int f(); return 3; endfunction function int g(int a); return a; endfunction endmodule
module top(output int o, p, q);
  sub i0 ();
  assign o = i0.f( );
  assign p = i0.f() + i0.g(i0.f());
  assign q = i0.g(i0.g(2));
endmodule
