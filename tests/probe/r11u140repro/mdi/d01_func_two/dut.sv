// § multiDeclOneItem140
package p;
  function automatic logic [7:0] gf(input logic [7:0] x);
    logic [7:0] result, temp;
    result = 8'h00;
    temp = x;
    result = result ^ temp;
    return result;
  endfunction
endpackage
module top(input logic [7:0] a, output logic [7:0] o);
  assign o = p::gf(a);
endmodule
