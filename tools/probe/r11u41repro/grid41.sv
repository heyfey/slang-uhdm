// r11u41 golden grid: the struct-bound type parameter, kind x dims x position
package pk;
  typedef enum logic [2:0] { PE0, PE1, PE2 } pe_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } ps_t;
  typedef struct packed { logic [3:0] a; ps_t inner; } psn_t;
  typedef struct packed { logic [3:0] a; bit   [3:0] b; } psb_t;
  typedef struct packed { logic [3:0] a; pe_t  e;       } pse_t;
endpackage

module a_tps_nod_net import pk::*; #(parameter type T_tps  = pk::ps_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps x_tps_nod_net;
  assign sink = |{x_tps_nod_net};
endmodule

module a_tps_nod_in import pk::*; #(parameter type T_tps  = pk::ps_t) (
    input  T_tps x_tps_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_nod_in};
endmodule

module a_tps_nod_out import pk::*; #(parameter type T_tps  = pk::ps_t) (
    output T_tps x_tps_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_nod_out};
endmodule

module a_tps_pk_net import pk::*; #(parameter type T_tps  = pk::ps_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps [1:0] x_tps_pk_net;
  assign sink = |{x_tps_pk_net};
endmodule

module a_tps_pk_in import pk::*; #(parameter type T_tps  = pk::ps_t) (
    input  T_tps [1:0] x_tps_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_pk_in};
endmodule

module a_tps_pk_out import pk::*; #(parameter type T_tps  = pk::ps_t) (
    output T_tps [1:0] x_tps_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tps_pk_out};
endmodule

module a_tps_unp_net import pk::*; #(parameter type T_tps  = pk::ps_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tps x_tps_unp_net [1:0];
  assign sink = |{x_tps_unp_net[0]};
endmodule

module a_tpso_nod_net import pk::*; #(parameter type T_tpso = logic) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpso x_tpso_nod_net;
  assign sink = |{x_tpso_nod_net};
endmodule

module a_tpso_nod_in import pk::*; #(parameter type T_tpso = logic) (
    input  T_tpso x_tpso_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpso_nod_in};
endmodule

module a_tpso_nod_out import pk::*; #(parameter type T_tpso = logic) (
    output T_tpso x_tpso_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpso_nod_out};
endmodule

module a_tpso_pk_net import pk::*; #(parameter type T_tpso = logic) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpso [1:0] x_tpso_pk_net;
  assign sink = |{x_tpso_pk_net};
endmodule

module a_tpso_pk_in import pk::*; #(parameter type T_tpso = logic) (
    input  T_tpso [1:0] x_tpso_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpso_pk_in};
endmodule

module a_tpso_pk_out import pk::*; #(parameter type T_tpso = logic) (
    output T_tpso [1:0] x_tpso_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpso_pk_out};
endmodule

module a_tpso_unp_net import pk::*; #(parameter type T_tpso = logic) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpso x_tpso_unp_net [1:0];
  assign sink = |{x_tpso_unp_net[0]};
endmodule

module a_tpsn_nod_net import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsn x_tpsn_nod_net;
  assign sink = |{x_tpsn_nod_net};
endmodule

module a_tpsn_nod_in import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    input  T_tpsn x_tpsn_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsn_nod_in};
endmodule

module a_tpsn_nod_out import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    output T_tpsn x_tpsn_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsn_nod_out};
endmodule

module a_tpsn_pk_net import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsn [1:0] x_tpsn_pk_net;
  assign sink = |{x_tpsn_pk_net};
endmodule

module a_tpsn_pk_in import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    input  T_tpsn [1:0] x_tpsn_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsn_pk_in};
endmodule

module a_tpsn_pk_out import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    output T_tpsn [1:0] x_tpsn_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsn_pk_out};
endmodule

module a_tpsn_unp_net import pk::*; #(parameter type T_tpsn = pk::psn_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsn x_tpsn_unp_net [1:0];
  assign sink = |{x_tpsn_unp_net[0]};
endmodule

module a_tpsb_nod_net import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsb x_tpsb_nod_net;
  assign sink = |{x_tpsb_nod_net};
endmodule

module a_tpsb_nod_in import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    input  T_tpsb x_tpsb_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsb_nod_in};
endmodule

module a_tpsb_nod_out import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    output T_tpsb x_tpsb_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsb_nod_out};
endmodule

module a_tpsb_pk_net import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsb [1:0] x_tpsb_pk_net;
  assign sink = |{x_tpsb_pk_net};
endmodule

module a_tpsb_pk_in import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    input  T_tpsb [1:0] x_tpsb_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsb_pk_in};
endmodule

module a_tpsb_pk_out import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    output T_tpsb [1:0] x_tpsb_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpsb_pk_out};
endmodule

module a_tpsb_unp_net import pk::*; #(parameter type T_tpsb = pk::psb_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpsb x_tpsb_unp_net [1:0];
  assign sink = |{x_tpsb_unp_net[0]};
endmodule

module a_tpse_nod_net import pk::*; #(parameter type T_tpse = pk::pse_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpse x_tpse_nod_net;
  assign sink = |{x_tpse_nod_net};
endmodule

module a_tpse_nod_in import pk::*; #(parameter type T_tpse = pk::pse_t) (
    input  T_tpse x_tpse_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpse_nod_in};
endmodule

module a_tpse_nod_out import pk::*; #(parameter type T_tpse = pk::pse_t) (
    output T_tpse x_tpse_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpse_nod_out};
endmodule

module a_tpse_pk_net import pk::*; #(parameter type T_tpse = pk::pse_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpse [1:0] x_tpse_pk_net;
  assign sink = |{x_tpse_pk_net};
endmodule

module a_tpse_pk_in import pk::*; #(parameter type T_tpse = pk::pse_t) (
    input  T_tpse [1:0] x_tpse_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpse_pk_in};
endmodule

module a_tpse_pk_out import pk::*; #(parameter type T_tpse = pk::pse_t) (
    output T_tpse [1:0] x_tpse_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_tpse_pk_out};
endmodule

module a_tpse_unp_net import pk::*; #(parameter type T_tpse = pk::pse_t) (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  T_tpse x_tpse_unp_net [1:0];
  assign sink = |{x_tpse_unp_net[0]};
endmodule

module a_tds_nod_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t x_tds_nod_net;
  assign sink = |{x_tds_nod_net};
endmodule

module a_tds_pk_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t [1:0] x_tds_pk_net;
  assign sink = |{x_tds_pk_net};
endmodule

module a_tds_unp_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  s_t x_tds_unp_net [1:0];
  assign sink = |{x_tds_unp_net[0]};
endmodule

module a_pks_nod_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  ps_t x_pks_nod_net;
  assign sink = |{x_pks_nod_net};
endmodule

module a_pks_nod_in import pk::*; (
    input  ps_t x_pks_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pks_nod_in};
endmodule

module a_pks_nod_out import pk::*; (
    output ps_t x_pks_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pks_nod_out};
endmodule

module a_pks_pk_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  ps_t [1:0] x_pks_pk_net;
  assign sink = |{x_pks_pk_net};
endmodule

module a_pks_pk_in import pk::*; (
    input  ps_t [1:0] x_pks_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pks_pk_in};
endmodule

module a_pks_pk_out import pk::*; (
    output ps_t [1:0] x_pks_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pks_pk_out};
endmodule

module a_pks_unp_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  ps_t x_pks_unp_net [1:0];
  assign sink = |{x_pks_unp_net[0]};
endmodule

module a_pksq_nod_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::ps_t x_pksq_nod_net;
  assign sink = |{x_pksq_nod_net};
endmodule

module a_pksq_nod_in import pk::*; (
    input  pk::ps_t x_pksq_nod_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pksq_nod_in};
endmodule

module a_pksq_nod_out import pk::*; (
    output pk::ps_t x_pksq_nod_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pksq_nod_out};
endmodule

module a_pksq_pk_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::ps_t [1:0] x_pksq_pk_net;
  assign sink = |{x_pksq_pk_net};
endmodule

module a_pksq_pk_in import pk::*; (
    input  pk::ps_t [1:0] x_pksq_pk_in,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pksq_pk_in};
endmodule

module a_pksq_pk_out import pk::*; (
    output pk::ps_t [1:0] x_pksq_pk_out,
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  assign sink = |{x_pksq_pk_out};
endmodule

module a_pksq_unp_net import pk::*; (
    output logic sink
);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  pk::ps_t x_pksq_unp_net [1:0];
  assign sink = |{x_pksq_unp_net[0]};
endmodule

module tb;
  logic sink;
  a_tps_nod_net i0 (.sink(sink));
  a_tps_nod_in i1 (.sink(sink));
  a_tps_nod_out i2 (.sink(sink));
  a_tps_pk_net i3 (.sink(sink));
  a_tps_pk_in i4 (.sink(sink));
  a_tps_pk_out i5 (.sink(sink));
  a_tps_unp_net i6 (.sink(sink));
  a_tpso_nod_net #(.T_tpso(pk::ps_t)) i7 (.sink(sink));
  a_tpso_nod_in #(.T_tpso(pk::ps_t)) i8 (.sink(sink));
  a_tpso_nod_out #(.T_tpso(pk::ps_t)) i9 (.sink(sink));
  a_tpso_pk_net #(.T_tpso(pk::ps_t)) i10 (.sink(sink));
  a_tpso_pk_in #(.T_tpso(pk::ps_t)) i11 (.sink(sink));
  a_tpso_pk_out #(.T_tpso(pk::ps_t)) i12 (.sink(sink));
  a_tpso_unp_net #(.T_tpso(pk::ps_t)) i13 (.sink(sink));
  a_tpsn_nod_net i14 (.sink(sink));
  a_tpsn_nod_in i15 (.sink(sink));
  a_tpsn_nod_out i16 (.sink(sink));
  a_tpsn_pk_net i17 (.sink(sink));
  a_tpsn_pk_in i18 (.sink(sink));
  a_tpsn_pk_out i19 (.sink(sink));
  a_tpsn_unp_net i20 (.sink(sink));
  a_tpsb_nod_net i21 (.sink(sink));
  a_tpsb_nod_in i22 (.sink(sink));
  a_tpsb_nod_out i23 (.sink(sink));
  a_tpsb_pk_net i24 (.sink(sink));
  a_tpsb_pk_in i25 (.sink(sink));
  a_tpsb_pk_out i26 (.sink(sink));
  a_tpsb_unp_net i27 (.sink(sink));
  a_tpse_nod_net i28 (.sink(sink));
  a_tpse_nod_in i29 (.sink(sink));
  a_tpse_nod_out i30 (.sink(sink));
  a_tpse_pk_net i31 (.sink(sink));
  a_tpse_pk_in i32 (.sink(sink));
  a_tpse_pk_out i33 (.sink(sink));
  a_tpse_unp_net i34 (.sink(sink));
  a_tds_nod_net i35 (.sink(sink));
  a_tds_pk_net i36 (.sink(sink));
  a_tds_unp_net i37 (.sink(sink));
  a_pks_nod_net i38 (.sink(sink));
  a_pks_nod_in i39 (.sink(sink));
  a_pks_nod_out i40 (.sink(sink));
  a_pks_pk_net i41 (.sink(sink));
  a_pks_pk_in i42 (.sink(sink));
  a_pks_pk_out i43 (.sink(sink));
  a_pks_unp_net i44 (.sink(sink));
  a_pksq_nod_net i45 (.sink(sink));
  a_pksq_nod_in i46 (.sink(sink));
  a_pksq_nod_out i47 (.sink(sink));
  a_pksq_pk_net i48 (.sink(sink));
  a_pksq_pk_in i49 (.sink(sink));
  a_pksq_pk_out i50 (.sink(sink));
  a_pksq_unp_net i51 (.sink(sink));
endmodule
