// § tfItemInitLocalAtType209: an initialized local whose initializer spans lines in a paren-less class method
package p;
  class c;
    int q[$];
    function int f;
      int total =
        q.size() +
        1;
      byte unsigned b = 8'hff;
      return total + b;
    endfunction
  endclass
endpackage
module top;
endmodule
