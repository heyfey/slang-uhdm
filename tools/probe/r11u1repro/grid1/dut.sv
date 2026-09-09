package p;
  typedef struct { int unsigned DAT; } bus_t;
  typedef struct { bus_t BUS; } cfg_t;
  localparam cfg_t CFG_DEF = '{BUS: '{DAT: 32}};
  localparam cfg_t CFG_OVR = '{BUS: '{DAT: 64}};
endpackage

interface tif #(parameter int W = 16, parameter p::cfg_t CFG = p::CFG_DEF);
  localparam int unsigned BYT = CFG.BUS.DAT/8;
  logic [W-1:0] d;
  modport mp (input d);
endinterface

module m_mp_named  (tif.mp  q, output logic o); assign o = q.d[0]; localparam int L = q.BYT; endmodule
module m_mp_pos    (tif.mp  q, output logic o); assign o = q.d[0]; endmodule
module m_pl_named  (tif      q, output logic o); assign o = q.d[0]; endmodule
module m_pl_pos    (tif      q, output logic o); assign o = q.d[0]; endmodule
module m_arr       (tif.mp  q, output logic o); assign o = q.d[0]; endmodule

module top (output logic [7:0] o);
  tif #(.W(32), .CFG(p::CFG_OVR)) u_ov ();
  tif u_df ();
  tif #(.W(8)) arr [2] ();

  m_mp_named a0 (.q(u_ov.mp), .o(o[0]));
  m_mp_pos   a1 (u_ov.mp, o[1]);
  m_pl_named a2 (.q(u_ov),    .o(o[2]));
  m_pl_pos   a3 (u_ov, o[3]);
  m_arr      a4 (.q(arr[0].mp), .o(o[4]));
  m_mp_named a5 (.q(u_df.mp), .o(o[5]));
  if (1) begin : g
    m_mp_named a6 (.q(u_ov.mp), .o(o[6]));
  end
endmodule
