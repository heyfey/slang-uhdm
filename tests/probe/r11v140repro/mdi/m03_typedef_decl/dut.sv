// § multiDeclOneItem140
package p; typedef logic [3:0] n_t; endpackage
module top(input logic [3:0] x, output logic [3:0] o);
  function automatic logic [3:0] f(input logic [3:0] v);
    p::n_t a, b;
    a = v;
    b = ~a;
    return b;
  endfunction
  assign o = f(x);
endmodule
