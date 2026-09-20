// w8_tparam -- TYPE PARAMETERS: aliasBind67 must decline every one of them.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
module w8 #(parameter type T = logic [1:0]) ();
  typedef T       tt_t;
  typedef T [1:0] tw_t;
  T      x01;
  wire T x02;
  tt_t   x03;
  wire tt_t x04;
  tw_t   x05;
  wire tw_t x06;
endmodule
module w8b #(parameter type U = pk::cv_t) ();
  typedef U u2_t;
  U      x07;
  wire U x08;
  u2_t   x09;
  wire u2_t x10;
endmodule
module w8top;
  w8  a ();
  w8b b ();
endmodule
