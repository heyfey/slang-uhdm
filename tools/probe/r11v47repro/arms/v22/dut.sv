module dut;
  localparam int W = 8;
  localparam bit EN = 1;
  generate
    if (EN) begin : gb
      localparam type it_t = struct packed { logic [W-1:0] x; logic [3:0] y; };
      localparam it_t I = '{x: 8'd1, y: 4'd2};
      logic [11:0] z;
      initial z = I;
    end
  endgenerate
endmodule
