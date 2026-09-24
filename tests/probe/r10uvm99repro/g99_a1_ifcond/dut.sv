// r10uvm99 arm a1: `inside` in an IF CONDITION inside a function, module scope.
module zeta99;
  localparam int LOB = 2;
  localparam int HIB = 9;
  int bag99 [$];
  function automatic bit k1(int wv);
    if (wv inside {[1:3]}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k2(int wv);
    if (wv inside {4, [6:8], 11}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k3(int wv);
    if (wv inside {[LOB:HIB]}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k4(int wv);
    if (wv inside {[1:$]}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k5(int wv);
    if (wv inside {7}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k6(int wv);
    if (wv inside {bag99}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k7(int wv, int pv);
    if (wv inside {pv + 1, 5}) return 1'b1;
    return 1'b0;
  endfunction
  function automatic bit k8(int wv, int pv);
    if (wv inside {[pv+1:pv+4]}) return 1'b1;
    return 1'b0;
  endfunction
endmodule
