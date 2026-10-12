// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int);
    int a;
    function void x1();
      a = int'(T::K);
      a = int'(T::get);
      a = int'(T::get(1, 2));
      a = byte'(T::get());
      a = signed'(T::get());
      a = const'(T::get());
    endfunction
  endclass
  class gen2 #(type T = int) extends gen #(T);
    function void x2(); a = int'(T::nested::get()); endfunction
  endclass
endpackage
module top; endmodule
