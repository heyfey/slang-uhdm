// b07: 3-deep hierarchy, same param name reused at each level, plus a param
// whose default reads a parent param that is itself an unsized literal.
module b07_leaf #(parameter P = 'h1) ();
  localparam LP = 'h2;
  initial $display(P, LP);
endmodule
module b07_mid #(parameter P = 'h3) ();
  localparam LP = P;
  b07_leaf        a();
  b07_leaf #(.P(P)) b();
  b07_leaf #(.P('hA)) c();
  initial $display(LP);
endmodule
module b07_top;
  parameter P = 'h4;
  b07_mid          m0();
  b07_mid #(.P(P)) m1();
  b07_mid #(.P('hB)) m2();
endmodule
