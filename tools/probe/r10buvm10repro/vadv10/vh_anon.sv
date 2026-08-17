package ph10;
  typedef bit [3:0] th_bit;
  typedef th_bit    th_bit_c;
endpackage
module vhTop10;
  import ph10::*;
  enum th_bit   { A0 = 0, A1 = 1 } av1;   // INLINE anon enum, typedef base
  enum th_bit_c { B0 = 0, B1 = 1 } av2;   // INLINE anon enum, CHAINED base
  enum bit[3:0] { C0 = 0, C1 = 1 } av3;   // control
  struct packed { enum th_bit { D0 = 0, D1 = 1 } f; bit [3:0] g; } sv1;
endmodule
