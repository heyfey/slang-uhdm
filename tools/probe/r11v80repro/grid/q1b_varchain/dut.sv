// v11u80 q1b -- the same seam on the VARIABLE road, chains included.
package pq1b;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;
  typedef sl_t sl2_t;
  typedef struct packed { int x; logic [7:0] y; } si_t;
  typedef si_t si2_t;
  typedef union packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef un_t un2_t;
  typedef enum logic [1:0] { QA, QB } en_t;
  typedef en_t en2_t;
  typedef reg [7:0] r_t;
  typedef r_t r2_t;
  r_t    q_vr    [0:1];
  r2_t   q_vr2   [0:1];
  sl2_t  q_vsl2  [0:1];
  si2_t  q_vsi2  [0:1];
  en2_t  q_ven2  [0:1];
  un2_t  q_vun2  [0:1];
endpackage

module dut (output logic [31:0] o);
  import pq1b::*;
  assign o = {24'd0, q_vr[0]} ^ {24'd0, q_vr2[0]} ^ {16'd0, q_vsl2[0]}
           ^ {24'd0, q_vsi2[0].y} ^ {30'd0, q_ven2[0]} ^ {16'd0, q_vun2[0].a};
endmodule
