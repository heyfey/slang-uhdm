// § multiDeclOneItem140
module top(input logic [7:0] a, output logic [7:0] o);
  function automatic logic [7:0] g(input logic [7:0] x);
    int i;
    int j;
    i = x;
    j = i + 1;
    return j;
  endfunction
  assign o = g(a);
endmodule
