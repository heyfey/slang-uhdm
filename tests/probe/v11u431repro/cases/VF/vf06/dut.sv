// § caFnArgConcatFormalTs431 (a package function and a typedef formal)
package pk;
  typedef logic [5:0] b_t;
  function automatic logic [3:0] f(input b_t b);
    return b[3:0];
  endfunction
endpackage
module top(input [5:0] a, output [3:0] y);
assign y = pk::f({a[2:0], a[5:3]});
endmodule
