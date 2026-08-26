package pm2;
  typedef struct packed { logic [64:0] a65; logic [7:0] b8; } w2_t;
  typedef struct packed { logic [127:0] a128; logic [7:0] b8; } h2_t;
endpackage
module v99_mask2 (input logic s, input pm2::w2_t din, input pm2::h2_t hin,
                  output pm2::w2_t d_direct, output pm2::w2_t d_tern,
                  output pm2::h2_t h_direct, output pm2::h2_t h_tern,
                  output pm2::h2_t h_ddef,   output pm2::h2_t h_tdef);
  assign d_direct = '{ a65 : '1, b8 : '1 };
  assign d_tern   = s ? din : '{ a65 : '1, b8 : '1 };
  assign h_direct = '{ a128 : '1, b8 : '1 };
  assign h_tern   = s ? hin : '{ a128 : '1, b8 : '1 };
  assign h_ddef   = '{ default : '1 };
  assign h_tdef   = s ? hin : '{ default : '1 };
endmodule
