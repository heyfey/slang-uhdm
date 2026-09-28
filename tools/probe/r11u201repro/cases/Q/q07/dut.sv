// § opCtxRefArgBare201
package pk;
  function automatic logic [3:0] pf(input logic [3:0] x); return ~x; endfunction
endpackage
module top (input logic c, input logic [3:0] a, input logic [3:0] p1 [4], input logic [7:0] w, output logic [3:0] y1, output logic [3:0] y2, output logic [3:0] y3);
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x ^ 4'h5; endfunction
  assign y1 = pk::pf(a) + 4'd1;
  assign y2 = (f(a));
  assign y3 = -f(a);
endmodule
