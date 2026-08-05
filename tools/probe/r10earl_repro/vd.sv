// r10earl10 witness: a DEF-VIEW GEN-IF CONDITION reading a package parameter
// with its QUALIFIER.  tlul_socket_m1.sv:168 `if (tlul_pkg::ArbiterImpl ==
// "PPC")` — golden substitutes the package parameter's own constant
// (ct 6 / size 24 / "PPC"), we keep a ref_obj named `tlul_pkg::ArbiterImpl`.
// § genCondImportFold9 already folds the BARE (materialized-import) spelling
// and only for INTEGER values; rows here split qualified/bare, string/int,
// and keep a module-local control.
package vdp;
  parameter ArbiterImpl = "PPC";
  parameter string TypedImpl = "PPC";
  parameter int NW = 5;
  parameter logic [7:0] BW = 8'd9;
endpackage

module vdsub (input logic a, output logic b);
  assign b = a;
endmodule

module vd
  import vdp::*;
(
  input  logic a,
  output logic o
);
  localparam string LocalImpl = "PPC";
  localparam int    LocalNW   = 5;
  logic t1, t2, t3, t4, t5, t6;

  // A: QUALIFIED package STRING parameter (the corpus shape)
  if (vdp::ArbiterImpl == "PPC") begin : gen_qs
    vdsub u1 (.a(a), .b(t1));
  end else begin : gen_qs_e
    vdsub u1b (.a(a), .b(t1));
  end

  // B: QUALIFIED package INT parameter
  if (vdp::NW > 3) begin : gen_qi
    vdsub u2 (.a(a), .b(t2));
  end else begin : gen_qi_e
    vdsub u2b (.a(a), .b(t2));
  end

  // C: QUALIFIED package based-literal parameter
  if (vdp::BW > 3) begin : gen_qb
    vdsub u3 (.a(a), .b(t3));
  end else begin : gen_qb_e
    vdsub u3b (.a(a), .b(t3));
  end

  // D: BARE (wildcard-imported) string parameter
  if (ArbiterImpl == "PPC") begin : gen_bs
    vdsub u4 (.a(a), .b(t4));
  end else begin : gen_bs_e
    vdsub u4b (.a(a), .b(t4));
  end

  // E: QUALIFIED string-TYPED package parameter
  if (vdp::TypedImpl == "PPC") begin : gen_qt
    vdsub u5 (.a(a), .b(t5));
  end else begin : gen_qt_e
    vdsub u5b (.a(a), .b(t5));
  end

  // F: MODULE-LOCAL localparam — the negative control
  if (LocalNW > 3) begin : gen_loc
    vdsub u6 (.a(a), .b(t6));
  end else begin : gen_loc_e
    vdsub u6b (.a(a), .b(t6));
  end

  assign o = t1 ^ t2 ^ t3 ^ t4 ^ t5 ^ t6;
endmodule
