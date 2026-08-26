package pm3;
  typedef struct packed { logic [64:0] a65; logic [7:0] b8; } w2_t;
  typedef struct packed { logic [127:0] a128; logic [7:0] b8; } h2_t;
  typedef struct packed { logic [7:0] p8; logic [64:0] q65; logic [3:0] r4; } m3_t;
endpackage
module msub3 (input logic s, input logic [7:0] d, output pm3::w2_t o1,
              output pm3::h2_t o2, output pm3::m3_t o3, output pm3::m3_t o4);
  pm3::w2_t wint;
  assign wint = '{ a65 : '1, b8 : '1 };
  assign o1 = wint;
  assign o2 = '{ a128 : '1, b8 : d };
  assign o3 = '{ p8 : '1, q65 : '1, r4 : d[3:0] };
  assign o4 = '{ p8 : d, q65 : 65'd1, r4 : 4'h3 };
endmodule
module v99_mask3 (input logic s, input logic [7:0] d, output pm3::w2_t o1,
                  output pm3::h2_t o2, output pm3::m3_t o3, output pm3::m3_t o4);
  msub3 u (.s(s), .d(d), .o1(o1), .o2(o2), .o3(o3), .o4(o4));
endmodule
