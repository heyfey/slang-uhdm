// (r11u191 N0215) a default reading a system call and a concatenation of formals
package q;
  function automatic int f(logic [7:0] a, int w = $bits(a) + 1, logic [15:0] c = {a, a});
    return w;
  endfunction
endpackage
module top; endmodule
