module dut;
  localparam int W = 8;
  localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
  localparam it_t I = '{x: 8'd1, y: 4'd2};
  function automatic logic [W-1:0] f(it_t p);
    it_t lv;
    lv = p;
    return lv.x + I.x;
  endfunction
  logic [7:0] z;
  initial z = f(I);
endmodule
