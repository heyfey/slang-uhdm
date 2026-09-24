package pk;
  function automatic int pf(input int n);
    int r = 0;
    while (r < n) r = r + 2;
    return r;
  endfunction
endpackage
module top import pk::*; (input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (pf(5) == 6) ? 32'd7 : '0;
  end
endmodule
