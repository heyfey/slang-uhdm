package p;
  typedef struct { int unsigned DAT; } bus_t;
  typedef struct { bus_t BUS; } cfg_t;
  localparam cfg_t CFG_DEF = '{BUS: '{DAT: 32}};
endpackage

interface tif #(parameter int W = 16, parameter p::cfg_t CFG = p::CFG_DEF);
  localparam int unsigned BYT = CFG.BUS.DAT/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module m_mp_named  (tif.mp  q, output logic o); assign o = q.d[0]; endmodule
module m_mp_pos    (tif.mp  q, output logic o); assign o = q.d[0]; endmodule
module m_pl_named  (tif      q, output logic o); assign o = q.d[0]; endmodule
module m_pl_pos    (tif      q, output logic o); assign o = q.d[0]; endmodule

module top (output logic [7:0] o);
  tif u_df ();
  m_mp_named a0 (.q(u_df.mp), .o(o[0]));
  m_mp_pos   a1 (u_df.mp, o[1]);
  m_pl_named a2 (.q(u_df),    .o(o[2]));
  m_pl_pos   a3 (u_df, o[3]);
  if (1) begin : g
    m_mp_named a6 (.q(u_df.mp), .o(o[6]));
  end
endmodule
