// § genIpsBoundOwner256 (the select a named function-call argument in a for-generate)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
module m import fp::*; (input logic [7:0] a, output logic [3:0] o);
  function automatic logic f(input logic [2:0] x); return ^x; endfunction
  for (genvar i = 0; i < 4; i++) begin : gb
    assign o[i] = f(.x(a[FW +: PW]));
  end
endmodule
module top(input logic [7:0] a, output logic [3:0] o); m u (.*); endmodule
