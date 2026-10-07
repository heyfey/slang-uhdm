// § tfLocalArrRangeDimEnd275 — a parameter-expression ranged local array in a module function
module dut #(parameter int N = 4) (output int o);
  function automatic int f(int s);
    int v [0:N-1];
    v[1] = s;
    return v[1];
  endfunction
  assign o = f(3);
endmodule
