// § castInvalidOperandSyntax292
package p;
  typedef logic [7:0] b_t;
  typedef enum logic [1:0] {A, B} e_t;
  class gen #(type T = int);
    static bit m;
    function void x1();
      int i;
      string s;
      i = unsigned'(T::get());
      i = b_t'(T::get());
      i = e_t'(T::get());
      s = string'(T::get());
      i = 8'(T::get() + 1);
      i = int'((T::get()));
      i = int'(T::get().x);
      i = int'(f(T::get()));
      i = int'(T::get()) + int'(T::get());
      i = $signed(T::get());
    endfunction
    function int f(int a); return a; endfunction
  endclass
endpackage
module top; endmodule
