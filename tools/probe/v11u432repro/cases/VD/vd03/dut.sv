// § unitParamSizeDimWide432
parameter D = 5;
module m(input clk);
  typedef struct { logic [3:0] f [D]; } s_t;
  s_t s;
  for (genvar i = 0; i < 2; i++) begin : g
    logic [3:0] r [D];
  end
endmodule
