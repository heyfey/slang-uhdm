// § fixArrLocalNamedAggElemTs480 (package function never called nor imported)
package p;
  typedef enum logic [2:0] { I0, I1, I2 } e_t;
  function automatic logic [2:0] f();
    e_t arr[3];
    arr[2] = I2;
    return arr[2];
  endfunction
endpackage
module top;
  logic x;
endmodule
