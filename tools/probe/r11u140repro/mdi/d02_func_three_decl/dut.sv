// § multiDeclOneItem140
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] g(input logic [7:0] x);
    int i, j, k;
    i = x;
    j = i + 1;
    k = j + 1;
    return k;
  endfunction
  assign o = g(a);
endmodule
