// § castClsTpOwnDefaultObj298
// a shortreal default and a realtime default
package p;
  class gen #(type R = shortreal, type Q = realtime);
    real z;
    function void f(); z = R'(1); z = Q'(2); endfunction
  endclass
endpackage
module top; endmodule
