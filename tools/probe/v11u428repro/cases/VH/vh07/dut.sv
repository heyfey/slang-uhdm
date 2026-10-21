// § hpMacroSelDispExpanded428
`define F(x) x
typedef struct packed { logic [31:0] data; } pkt_t;
module top(input pkt_t p, output [1:0][7:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = p.data[f(`F(i))+:4];
  end
  function automatic integer f(integer k); return 4*k; endfunction
endmodule
