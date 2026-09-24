interface j11_if (input logic clk);
  function automatic int plain(int x);
    return x + 1;
  endfunction
endinterface
module j11_top;
  logic c;
  j11_if u(.clk(c));
endmodule
