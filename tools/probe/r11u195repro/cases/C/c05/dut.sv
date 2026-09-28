// § evalFuncExecCallArgTs191 — fresh: nested calls (the inner call's actual evaluated first) and an indexed part select with a descending width
module top(input logic [7:0] sig, output logic o);
  function automatic logic g(input logic [1:0] d);
    return |d;
  endfunction
  function automatic logic [1:0] m(input logic [3:0] d);
    return d[3:2];
  endfunction
  function automatic logic f(input logic [7:0] x);
    return g(m(x[7-:4]));
  endfunction
  assign o = f(sig);
endmodule
