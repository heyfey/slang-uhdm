// § castTypeParamDefaultKind292
package p;
  class base #(type T = byte);
    T v;
    function void f(); v = T'(7); endfunction
  endclass
  class der #(type T = shortint) extends base #(T);
    function void g(); v = T'(8); endfunction
  endclass
  class w #(type T = logic [7:0], type U = bit [3:0], type R = real);
    real z;
    function void h(); z = T'(1); z = U'(2); z = R'(3); endfunction
  endclass
endpackage
module top; endmodule
