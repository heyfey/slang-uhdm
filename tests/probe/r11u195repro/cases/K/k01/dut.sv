// § procNetMidSelDotted195 — grid K/k01 (r11u195)
package rp;
  typedef struct packed { logic [31:0] q; logic qe; } key_t;
  typedef struct packed { key_t [7:0] key; logic [3:0] ctrl; } reg2hw_t;
endpackage
module top(input rp::reg2hw_t reg2hw, output logic [7:0][31:0] key_init, output logic [7:0] key_init_qe);
  always_comb begin : key_init_get
    for (int i=0; i<8; i++) begin
      key_init[i]    = reg2hw.key[i].q;
      key_init_qe[i] = reg2hw.key[i].qe;
    end
  end
endmodule
