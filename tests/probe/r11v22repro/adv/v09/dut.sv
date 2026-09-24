module top(input logic [31:0] a, output logic [31:0] o);
  function automatic int fx(input int n);
    int r; r = 0;
    for (int i = 0; i < n; i++) r = r + i;
    return r;
  endfunction
  if (1) begin : gb
    assign o = (fx(4) > 3) ? 32'd7 : '0;
  end
endmodule
