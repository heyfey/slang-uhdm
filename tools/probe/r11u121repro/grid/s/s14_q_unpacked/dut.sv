package up;
  typedef struct { logic [7:0] a [2]; int b; } u_t;
  localparam u_t U = '{a: '{8'h12, 8'h34}, b: 7};
endpackage
module top (output logic [7:0] o, output logic [3:0] q);
  assign o = up::U.a[1];
  assign q = up::U.a[0][3:0];
endmodule
