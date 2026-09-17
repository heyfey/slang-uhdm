// v11u61 arm v6 — SCOPES: function-local, class-local, child def view
module v6child;
  typedef struct { byte b8; shortint s16; } u_t;
  localparam u_t UL = '{b8: 7, s16: 8};
endmodule

module v6;
  typedef struct { byte b8; shortint s16; } f_t;
  function automatic int f();
    localparam f_t FL = '{b8: 1, s16: 2};
    return FL.s16;
  endfunction
  localparam int R = f();
  localparam f_t ML = '{b8: 3, s16: 4};
  v6child ch();
endmodule
