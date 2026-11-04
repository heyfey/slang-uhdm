// § paramValRhsSharesParamConst273
module dut (output logic [7:0] o);
  typedef struct packed { logic [7:0] x; logic [7:0] y; } st_t;
  localparam int unsigned M = 200;
  st_t s;
  assign s.x = M;
  assign s.y = 8'd0;
  assign o = s.x;
endmodule
