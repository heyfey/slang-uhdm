// r11v81 adversarial arm v6 — a PACKED-ARRAY parameter pattern (not a
// struct) over package hops.
package v6p;
  localparam PH = 16'h5;
  localparam PD = 16'd5;
  localparam logic [3:0][23:0] AR = '{PH, PD, PH, PD};
  typedef struct packed { logic [23:0] bail; logic [23:0] a; } t6;
  localparam t6 N = '{bail: 8'hxA, a: PH};
endpackage
module v6_arr81 #(parameter v6p::t6 CN = v6p::N) (output logic [23:0] o);
  localparam logic [3:0][23:0] LAR = v6p::AR;
  assign o = CN.a ^ LAR[0] ^ LAR[1];
endmodule
