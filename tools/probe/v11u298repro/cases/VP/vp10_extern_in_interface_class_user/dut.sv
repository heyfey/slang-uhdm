// § castClsTpOutOfBodyPlaceholder298
// an extern function with a ranged return of U and a cast in a nested begin block
package p;
  class gen #(type U = logic [7:0]);
    U y;
    extern function U f(int a);
  endclass
  function gen::U gen::f(int a);
    begin
      y = U'(a);
    end
    return U'(a + 1);
  endfunction
endpackage
module top; endmodule
