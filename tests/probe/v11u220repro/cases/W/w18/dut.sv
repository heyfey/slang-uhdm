// § newArrayCallArgStripped220
package p;
  class c;
    int d[];
    static function int g(int a); return a; endfunction
    function void f(int n);
      d = new[c::g(n)];
    endfunction
  endclass
endpackage
module top; endmodule
