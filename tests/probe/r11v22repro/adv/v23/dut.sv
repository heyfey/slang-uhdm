module top(input logic [31:0] a, output logic [31:0] o);
  function automatic int fr(input int n);
    if (n <= 1) return 1;
    return n * fr(n-1);
  endfunction
  if (1) begin : gb
    assign o = (fr(4) == 24) ? 32'd7 : '0;
  end
endmodule
