module mfm62 #(parameter int W = 4) (input logic clk, output logic [1:0] z);
  import mfp62::*;
  typedef enum logic [1:0] { MA, MB, MC } m_e;
  typedef struct packed { m_e op; logic [1:0] sz; } m_t;
  m_t mv;
  pw_t pw;
  assign z = (mv.op == MB) ? mv.sz : {2{pw[0]}};
endmodule
