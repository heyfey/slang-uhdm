// § tfItemInitLocalAtType209: string and real locals with initializers in a paren-less class method
package p;
  class c;
    function int f;
      string s = "ab";
      real rr = 2.5;
      int n = s.len();
      return n;
    endfunction
  endclass
endpackage
module top;
endmodule
