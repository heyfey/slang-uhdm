// (r11u191 queue twin) a dynamic-array typedef returned by a package function
package p;
  typedef int dyn_t[];
  function automatic dyn_t mk(int n);
    dyn_t d;
    return d;
  endfunction
endpackage
module top; endmodule
