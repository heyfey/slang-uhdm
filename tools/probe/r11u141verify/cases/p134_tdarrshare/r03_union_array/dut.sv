// § defNetTypedefArrayShares134
// case r03: an unpacked array of a module union typedef, read by member
module top(output logic [3:0] o);
  typedef union packed { logic [7:0] w; struct packed { logic [3:0] h; logic [3:0] l; } p; } u_t;
  u_t f [2];
  assign f[0] = 8'hA5;
  assign o = f[0].p.h;
endmodule
