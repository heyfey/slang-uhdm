package pe10;
  typedef bit  te_bit;
  typedef te_bit te_bit_c;
  typedef enum te_bit  [3:0] { W0 = 0, W1 = 1 } e_dim;
  typedef enum te_bit_c[3:0] { Y0 = 0, Y1 = 1 } e_dim_c;
endpackage
module veTop10;
  pe10::e_dim   v1;
  pe10::e_dim_c v2;
endmodule
