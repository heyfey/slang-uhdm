// § tfArgQualOutsideWriter176 § tfArgDefTopSplit176
package pa;
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic int own(e_t x); return int'(x); endfunction
endpackage
module m1;
  function automatic int g1(pa::e_t x); return int'(x); endfunction
  initial $display(g1(pa::A));
endmodule
module m2;
  function automatic int g2(pa::e_t y); return int'(y); endfunction
  initial $display(g2(pa::B));
endmodule
interface i3;
  function automatic int g3(pa::e_t z); return int'(z); endfunction
endinterface
module top;
  m1 u1(); m2 u2(); i3 u3();
  initial $display(pa::own(pa::C));
endmodule
