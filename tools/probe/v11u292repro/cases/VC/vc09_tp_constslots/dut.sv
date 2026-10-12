// § castTypeParamDefaultLoc292
package p;
  class c #(type T = int, int N = T'(3));
    logic [T'(5):0] v;
    int a [T'(2)];
    function void f();
      v = {T'(2){1'b1}};
      v[T'(1) +: 2] = '0;
      v[T'(4):T'(3)] = 2'b10;
    endfunction
  endclass
  class d #(type T = byte);
    localparam int L = T'(7);
    function int g(); return L + T'(1); endfunction
  endclass
endpackage
module top; endmodule
