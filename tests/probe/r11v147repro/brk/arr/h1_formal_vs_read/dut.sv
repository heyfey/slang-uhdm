// § blockLhsVarSelBindsWholeRef151
module top(input logic [1:0][1:0] i, output logic [3:0] o, output logic p);
  function automatic logic f(input logic [1:0][1:0] a);
    logic [3:0] t;
    t = a;
    return a[0][1] ^ t[2];
  endfunction
  assign p = f(i);
  assign o = i;
endmodule
