// § enumConstUnderscoreDropped186 (a 20-digit value abstains, a 19-digit value)
module top(output longint unsigned o);
  typedef enum longint unsigned { A = 18_446_744_073_709_551_615, B = 1_000_000_000_000_000_000 } e_t;
  e_t v = B;
  assign o = v;
endmodule
