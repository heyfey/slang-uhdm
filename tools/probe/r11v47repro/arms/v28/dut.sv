module dut;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [W-1:0] y; };
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  function automatic logic cmpf(input it_t p, input it_t q);
    return (p.x == q.y);
  endfunction
  logic z;
  initial z = cmpf(I, I);
endmodule
