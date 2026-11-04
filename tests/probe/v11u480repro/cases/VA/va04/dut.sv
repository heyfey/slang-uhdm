// § fixArrLocalNamedAggElemTs480 (package enum with int base, package function called directly)
package p;
  typedef enum int { A = 3, B = 7 } e_t;
  function int f();
    e_t arr[2];
    arr[0] = B;
    return arr[0];
  endfunction
endpackage
module top;
  import p::*;
  int x;
  initial x = f();
endmodule
