// § implicitNetMintNoFile131
// case f04: foreach over a two-dimensional array inside a function
module top(input logic [3:0] a, output logic [3:0] y);
  function automatic logic [3:0] f(input logic [3:0] v);
    logic [3:0] m [2][2];
    logic [3:0] s;
    s = v;
    foreach (m[i, j]) s = s + i + j;
    return s;
  endfunction
  assign y = f(a);
endmodule
