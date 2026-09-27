// § enumConstUnderscoreDropped186 (negative, unsized based, typed base)
module top(output int o, output logic [7:0] p);
  typedef enum int { A = -1_0, B = 'd2_0, C = 3_0 } e_t;
  typedef enum logic [7:0] { X = 1_2, Y = 2_5_5 } f_t;
  e_t v = C;
  f_t w = Y;
  assign o = v;
  assign p = w;
endmodule
