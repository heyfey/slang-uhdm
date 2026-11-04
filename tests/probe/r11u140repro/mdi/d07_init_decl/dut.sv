// § multiDeclOneItem140
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] g(input logic [7:0] x);
    int i = 1, j = 2;
    i = i + x;
    return i + j;
  endfunction
  assign o = g(a);
endmodule
