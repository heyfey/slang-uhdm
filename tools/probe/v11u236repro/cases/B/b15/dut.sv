// § opArgCallCtx236v — operation actuals as an indexed part-select base and a bit-select index
module top (input int a, input logic [15:0] v, output logic [3:0] o, output logic o2);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = v[f(a + 1) +: 4];
  assign o2 = v[f(a - 1)];
endmodule
