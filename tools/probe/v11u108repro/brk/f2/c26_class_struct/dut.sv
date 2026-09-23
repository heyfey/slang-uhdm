package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  class C;
    typedef struct packed { logic [3:0] pad; row_t [0:1] U; } s_t;
    s_t v;
  endclass
  typedef struct packed { logic [3:0] pad; row_t [0:1] U; } s_t;
  localparam s_t P0 = '0;
endpackage
module dut (output logic [15:0] o);
  assign o = q2::P0;
endmodule
