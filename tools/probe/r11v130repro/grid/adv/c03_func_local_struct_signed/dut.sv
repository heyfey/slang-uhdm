// § suSigningNotInSpan130
module top(output logic [7:0] o);
  function automatic logic [7:0] f(input logic [7:0] i);
    struct packed signed { logic [3:0] a; logic [3:0] b; } s;
    s = i;
    return s;
  endfunction
  assign o = f(8'd3);
endmodule
