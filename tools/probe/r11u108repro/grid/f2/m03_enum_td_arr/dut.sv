package q2;
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t [0:2] ea_t;
  typedef struct packed { logic [3:0] pad; ea_t [0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [15:0] o);
  assign o = q2::P0;
endmodule
