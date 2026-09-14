// r11u32 golden grid: the named-type declaration, kind x dims x position
package pk;
  typedef logic [7:0] pl_t;
  typedef enum logic [2:0] { PE0, PE1, PE2 } pe_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
endpackage

module a_tp_nod_net import pk::*; #(parameter type T_tp  = logic [7:0]) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tp x_tp_nod_net;
  assign sink = |{x_tp_nod_net};
endmodule

module a_tp_nod_in import pk::*; #(parameter type T_tp  = logic [7:0]) (
    input  T_tp x_tp_nod_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tp_nod_in};
endmodule

module a_tp_nod_out import pk::*; #(parameter type T_tp  = logic [7:0]) (
    output T_tp x_tp_nod_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tp_nod_out};
endmodule

module a_tp_pk_net import pk::*; #(parameter type T_tp  = logic [7:0]) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tp [1:0] x_tp_pk_net;
  assign sink = |{x_tp_pk_net};
endmodule

module a_tp_pk_in import pk::*; #(parameter type T_tp  = logic [7:0]) (
    input  T_tp [1:0] x_tp_pk_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tp_pk_in};
endmodule

module a_tp_pk_out import pk::*; #(parameter type T_tp  = logic [7:0]) (
    output T_tp [1:0] x_tp_pk_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tp_pk_out};
endmodule

module a_tp_unp_net import pk::*; #(parameter type T_tp  = logic [7:0]) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tp x_tp_unp_net [1:0];
  assign sink = |{x_tp_unp_net[0]};
endmodule

module a_tpe_nod_net import pk::*; #(parameter type T_tpe = pk::pe_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpe x_tpe_nod_net;
  assign sink = |{x_tpe_nod_net};
endmodule

module a_tpe_nod_in import pk::*; #(parameter type T_tpe = pk::pe_t) (
    input  T_tpe x_tpe_nod_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpe_nod_in};
endmodule

module a_tpe_nod_out import pk::*; #(parameter type T_tpe = pk::pe_t) (
    output T_tpe x_tpe_nod_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpe_nod_out};
endmodule

module a_tpe_pk_net import pk::*; #(parameter type T_tpe = pk::pe_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpe [1:0] x_tpe_pk_net;
  assign sink = |{x_tpe_pk_net};
endmodule

module a_tpe_pk_in import pk::*; #(parameter type T_tpe = pk::pe_t) (
    input  T_tpe [1:0] x_tpe_pk_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpe_pk_in};
endmodule

module a_tpe_pk_out import pk::*; #(parameter type T_tpe = pk::pe_t) (
    output T_tpe [1:0] x_tpe_pk_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpe_pk_out};
endmodule

module a_tpe_unp_net import pk::*; #(parameter type T_tpe = pk::pe_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpe x_tpe_unp_net [1:0];
  assign sink = |{x_tpe_unp_net[0]};
endmodule

module a_tps_nod_net import pk::*; #(parameter type T_tps = pk::ps_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps x_tps_nod_net;
  assign sink = |{x_tps_nod_net};
endmodule

module a_tps_nod_in import pk::*; #(parameter type T_tps = pk::ps_t) (
    input  T_tps x_tps_nod_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_nod_in};
endmodule

module a_tps_nod_out import pk::*; #(parameter type T_tps = pk::ps_t) (
    output T_tps x_tps_nod_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_nod_out};
endmodule

module a_tps_pk_net import pk::*; #(parameter type T_tps = pk::ps_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps [1:0] x_tps_pk_net;
  assign sink = |{x_tps_pk_net};
endmodule

module a_tps_pk_in import pk::*; #(parameter type T_tps = pk::ps_t) (
    input  T_tps [1:0] x_tps_pk_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_pk_in};
endmodule

module a_tps_pk_out import pk::*; #(parameter type T_tps = pk::ps_t) (
    output T_tps [1:0] x_tps_pk_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_pk_out};
endmodule

module a_tps_unp_net import pk::*; #(parameter type T_tps = pk::ps_t) (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps x_tps_unp_net [1:0];
  assign sink = |{x_tps_unp_net[0]};
endmodule

module a_tdl_nod_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  l_t x_tdl_nod_net;
  assign sink = |{x_tdl_nod_net};
endmodule

module a_tdl_pk_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  l_t [1:0] x_tdl_pk_net;
  assign sink = |{x_tdl_pk_net};
endmodule

module a_tdl_unp_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  l_t x_tdl_unp_net [1:0];
  assign sink = |{x_tdl_unp_net[0]};
endmodule

module a_tde_nod_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  e_t x_tde_nod_net;
  assign sink = |{x_tde_nod_net};
endmodule

module a_tde_pk_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  e_t [1:0] x_tde_pk_net;
  assign sink = |{x_tde_pk_net};
endmodule

module a_tde_unp_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  e_t x_tde_unp_net [1:0];
  assign sink = |{x_tde_unp_net[0]};
endmodule

module a_tds_nod_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t x_tds_nod_net;
  assign sink = |{x_tds_nod_net};
endmodule

module a_tds_pk_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [1:0] x_tds_pk_net;
  assign sink = |{x_tds_pk_net};
endmodule

module a_tds_unp_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t x_tds_unp_net [1:0];
  assign sink = |{x_tds_unp_net[0]};
endmodule

module a_pkl_nod_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pl_t x_pkl_nod_net;
  assign sink = |{x_pkl_nod_net};
endmodule

module a_pkl_nod_in import pk::*; (
    input  pl_t x_pkl_nod_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pkl_nod_in};
endmodule

module a_pkl_nod_out import pk::*; (
    output pl_t x_pkl_nod_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pkl_nod_out};
endmodule

module a_pkl_pk_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pl_t [1:0] x_pkl_pk_net;
  assign sink = |{x_pkl_pk_net};
endmodule

module a_pkl_pk_in import pk::*; (
    input  pl_t [1:0] x_pkl_pk_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pkl_pk_in};
endmodule

module a_pkl_pk_out import pk::*; (
    output pl_t [1:0] x_pkl_pk_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pkl_pk_out};
endmodule

module a_pkl_unp_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pl_t x_pkl_unp_net [1:0];
  assign sink = |{x_pkl_unp_net[0]};
endmodule

module a_pklq_nod_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::pl_t x_pklq_nod_net;
  assign sink = |{x_pklq_nod_net};
endmodule

module a_pklq_nod_in import pk::*; (
    input  pk::pl_t x_pklq_nod_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pklq_nod_in};
endmodule

module a_pklq_nod_out import pk::*; (
    output pk::pl_t x_pklq_nod_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pklq_nod_out};
endmodule

module a_pklq_pk_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::pl_t [1:0] x_pklq_pk_net;
  assign sink = |{x_pklq_pk_net};
endmodule

module a_pklq_pk_in import pk::*; (
    input  pk::pl_t [1:0] x_pklq_pk_in,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pklq_pk_in};
endmodule

module a_pklq_pk_out import pk::*; (
    output pk::pl_t [1:0] x_pklq_pk_out,
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pklq_pk_out};
endmodule

module a_pklq_unp_net import pk::*; (
    output logic sink
);
  typedef logic [7:0] l_t;
  typedef enum logic [2:0] { E0, E1, E2 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::pl_t x_pklq_unp_net [1:0];
  assign sink = |{x_pklq_unp_net[0]};
endmodule

module tb;
  logic sink;
  a_tp_nod_net i0 (.sink(sink));
  a_tp_nod_in i1 (.sink(sink));
  a_tp_nod_out i2 (.sink(sink));
  a_tp_pk_net i3 (.sink(sink));
  a_tp_pk_in i4 (.sink(sink));
  a_tp_pk_out i5 (.sink(sink));
  a_tp_unp_net i6 (.sink(sink));
  a_tpe_nod_net i7 (.sink(sink));
  a_tpe_nod_in i8 (.sink(sink));
  a_tpe_nod_out i9 (.sink(sink));
  a_tpe_pk_net i10 (.sink(sink));
  a_tpe_pk_in i11 (.sink(sink));
  a_tpe_pk_out i12 (.sink(sink));
  a_tpe_unp_net i13 (.sink(sink));
  a_tps_nod_net i14 (.sink(sink));
  a_tps_nod_in i15 (.sink(sink));
  a_tps_nod_out i16 (.sink(sink));
  a_tps_pk_net i17 (.sink(sink));
  a_tps_pk_in i18 (.sink(sink));
  a_tps_pk_out i19 (.sink(sink));
  a_tps_unp_net i20 (.sink(sink));
  a_tdl_nod_net i21 (.sink(sink));
  a_tdl_pk_net i22 (.sink(sink));
  a_tdl_unp_net i23 (.sink(sink));
  a_tde_nod_net i24 (.sink(sink));
  a_tde_pk_net i25 (.sink(sink));
  a_tde_unp_net i26 (.sink(sink));
  a_tds_nod_net i27 (.sink(sink));
  a_tds_pk_net i28 (.sink(sink));
  a_tds_unp_net i29 (.sink(sink));
  a_pkl_nod_net i30 (.sink(sink));
  a_pkl_nod_in i31 (.sink(sink));
  a_pkl_nod_out i32 (.sink(sink));
  a_pkl_pk_net i33 (.sink(sink));
  a_pkl_pk_in i34 (.sink(sink));
  a_pkl_pk_out i35 (.sink(sink));
  a_pkl_unp_net i36 (.sink(sink));
  a_pklq_nod_net i37 (.sink(sink));
  a_pklq_nod_in i38 (.sink(sink));
  a_pklq_nod_out i39 (.sink(sink));
  a_pklq_pk_net i40 (.sink(sink));
  a_pklq_pk_in i41 (.sink(sink));
  a_pklq_pk_out i42 (.sink(sink));
  a_pklq_unp_net i43 (.sink(sink));
endmodule
