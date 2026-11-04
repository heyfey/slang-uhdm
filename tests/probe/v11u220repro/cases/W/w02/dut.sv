// § newArrayCallArgStripped220
package p1;
  class c;
    int arr[];
    function int g(int a); return a * 2; endfunction
    function void f(int n);
      arr = new[g(n)];
    endfunction
  endclass
endpackage
package p2;
  import p1::*;
endpackage
module top(output int o);
  import p2::*;
  assign o = 1;
endmodule
