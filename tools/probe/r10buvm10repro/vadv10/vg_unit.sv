typedef bit [3:0] tg_unit;
typedef tg_unit   tg_unit_c;
typedef enum tg_unit   { U0 = 0, U1 = 1 } e_unit;
typedef enum tg_unit_c { UC0 = 0, UC1 = 1 } e_unit_c;
module vgTop10;
  e_unit   v1;
  e_unit_c v2;
  typedef bit [2:0] tg_loc;
  typedef enum tg_loc { L0 = 0, L1 = 1 } e_loc;
  e_loc v3;
endmodule
