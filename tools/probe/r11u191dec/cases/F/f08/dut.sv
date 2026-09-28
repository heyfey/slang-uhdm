// (r11u191 N0215) a class method default casting a formal to an enum typedef of the class
class C;
  typedef enum { A, B } e_t;
  function void m(int a, e_t e = e_t'(a + 1), int z = (a > 0) ? int'(B) : 0);
  endfunction
endclass
module top; endmodule
