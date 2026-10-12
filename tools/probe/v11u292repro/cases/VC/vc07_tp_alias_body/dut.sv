// § castTypeParamDefaultLoc292
package p;
  class c #(type T = int);
    typedef T my_t;
    parameter type U = shortint;
    int y;
    function void f(); y = my_t'(3); y = U'(4); endfunction
  endclass
  class d #(type T = int, int N = 2);
    T arr[N];
    function void g(); arr[0] = T'(N); arr[1] = T'(arr[0] + 1); endfunction
  endclass
  class e #(type T = int);
    static function T mk(); return T'(9); endfunction
    function void h(); T z = T'(1); endfunction
  endclass
endpackage
module top; endmodule
