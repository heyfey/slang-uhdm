// § blockLhsVarSelBindsWholeRef151
module top(input logic [1:0][1:0] i, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [1:0][1:0] a);
    logic [3:0] t;
    a[1][0] = 1'b1;
    t = a;
    return t;
  endfunction
  assign o = f(i);
endmodule
