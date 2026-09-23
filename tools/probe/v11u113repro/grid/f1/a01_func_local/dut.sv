package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] a);
    logic [P:0] v;
    v = a[5:0];
    return {2'b0, v};
  endfunction
  assign o = f(i);
endmodule
