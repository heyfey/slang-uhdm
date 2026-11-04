// § castClsTpOwnDefaultObj298
// a string default
package p;
  class gen #(type S = string);
    string z;
    function void f(); z = S'("ab"); endfunction
  endclass
endpackage
module top; endmodule
