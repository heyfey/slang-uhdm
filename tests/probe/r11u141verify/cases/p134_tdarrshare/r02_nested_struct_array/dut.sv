// § defNetTypedefArrayShares134
// case r02: an unpacked array of a module struct typedef whose member is another struct typedef
module top(output logic [3:0] o);
  typedef struct packed { logic [1:0] x; logic [1:0] y; } in_t;
  typedef struct packed { in_t i; logic [3:0] z; } out_t;
  out_t f [2];
  assign f[1] = 8'h3C;
  assign o = {f[1].i.x, f[1].i.y};
endmodule
