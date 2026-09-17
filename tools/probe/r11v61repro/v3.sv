// v11u61 arm v3 — HOLDERS x COPY COUNTS x GENERATE
interface v3if ();
  typedef struct { byte b8; shortint s16; } t_t;
  localparam t_t IL = '{b8: 1, s16: 2};
endinterface

module v3child #(parameter int W = 1) (input logic clk);
  typedef struct { byte b8; shortint s16; } t_t;
  localparam t_t CL = '{b8: W, s16: 2};
endmodule

module v3;
  logic clk;
  typedef struct { byte b8; shortint s16; } t_t;
  localparam t_t TL = '{b8: 3, s16: 4};
  v3if u_if[2] ();
  v3child #(.W(5)) c0 (clk);
  v3child #(.W(6)) c1[2] (clk);
  for (genvar g = 0; g < 2; g++) begin : gb
    localparam t_t GL = '{b8: g, s16: 9};
    v3child #(.W(g+1)) gc (clk);
  end
endmodule
