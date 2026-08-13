// r10earl37 GRID a2 — the OVER-FIRE FENCE for the gen-scope DEF-view dotted
// port actual.  Every cell here is a DOTTED actual in a GENERATE block that is
// NOT the witness's shape, i.e. exactly what a widened gate could damage:
//
//   f_mp     modport-QUALIFIED actual on an INTERFACE port  (`ifc_i.mp`)
//   f_ifsig  an INTERFACE-PORT member read                  (`ifp.sig`)
//   f_ifloc  a LOCALLY instantiated interface's member       (`u_if.sig`)
//   f_selint a SELECT on an INTERIOR component (§ genConnDotSelInterior,
//            r10earl8's own cell — must stay byte-identical)
//   f_seltail a select at the TAIL (`s.addr[3:0]`)
//   f_hier   a HIERARCHICAL read out of a SIBLING gen branch
//   f_pkgc   a `::`-scoped actual with NO dot (the gate's dot conjunct)
//   f_arr    the MODULE-ARRAY carrier of the witness (ports hang off
//            module_array, not ref_module)
//   f_deep   three levels of member                        (`o.mid.inner.rd`)
package q38;
  typedef struct packed {
    logic       rd;
    logic [7:0] addr;
  } req_t;
  typedef struct packed {
    logic  en;
    req_t  inner;
  } mid_t;
  typedef struct packed {
    logic  top;
    mid_t  mid;
  } deep_t;
  localparam int PKW = 3;
endpackage

interface ifc38 ();
  logic sig;
  logic other;
  modport mp (input sig);
endinterface

module ch38 (
  input  logic       rd_i,
  input  logic [7:0] addr_i,
  output logic       ack_o
);
  assign ack_o = rd_i & addr_i[0];
endmodule

module ch38mp (
  ifc38.mp bus_i,
  output logic ack_o
);
  assign ack_o = bus_i.sig;
endmodule

module ch38w (
  input  int         w_i,
  output logic       ack_o
);
  assign ack_o = w_i[0];
endmodule

module top38 (
  input  q38::req_t        pin_i,
  input  q38::deep_t       deep_i,
  input  q38::req_t        uarr_i [0:1],
  ifc38.mp                 ifp,
  output logic [31:0]      ack_o
);

  ifc38 u_if ();
  ifc38 arr_if [0:1] ();
  logic sib_w;

  // f_parr — a MODULE ARRAY in the PLAIN body with a dotted actual (the
  // module_array conn loop, a DIFFERENT call site from the gen-scope one).
  ch38 i_parr [0:1] (
    .rd_i(pin_i.rd),
    .addr_i(pin_i.addr),
    .ack_o(ack_o[24 +: 2])
  );

  for (genvar b = 0; b < 2; b++) begin : gen_c
    // f_mp — modport-qualified actual on an INTERFACE port
    ch38mp i_mp (
      .bus_i(u_if.mp),
      .ack_o(ack_o[b])
    );
    // f_ifsig — an INTERFACE-PORT member read on a REGULAR port
    ch38 i_ifs (
      .rd_i(ifp.sig),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[2+b])
    );
    // f_ifloc — a LOCALLY instantiated interface's member
    ch38 i_ifl (
      .rd_i(u_if.other),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[4+b])
    );
    // f_selint — a select on an INTERIOR component (r10earl8's own cell)
    ch38 i_si (
      .rd_i(uarr_i[b].rd),
      .addr_i(uarr_i[b].addr),
      .ack_o(ack_o[6+b])
    );
    // f_seltail — a select at the TAIL
    ch38 i_st (
      .rd_i(pin_i.rd),
      .addr_i(pin_i.addr[7:0]),
      .ack_o(ack_o[8+b])
    );
    // f_hier — a HIERARCHICAL read out of the enclosing module's body
    ch38 i_hi (
      .rd_i(sib_w),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[10+b])
    );
    // f_pkgc — a `::`-scoped actual with NO dot
    ch38w i_pk (
      .w_i(q38::PKW),
      .ack_o(ack_o[12+b])
    );
    // f_deep — THREE levels of member
    ch38 i_dp (
      .rd_i(deep_i.mid.inner.rd),
      .addr_i(deep_i.mid.inner.addr),
      .ack_o(ack_o[14+b])
    );
    // f_mparr — a MODPORT-ARRAY member path (`arr_if[b].mp`): the leaf's
    // fullname is the RAW DOTTED text in golden (genVarBaseEmitted), NOT the
    // child-port scoping every other cell here takes — the counterexample any
    // widened stamp must abstain on.
    ch38mp i_ma (
      .bus_i(arr_if[b].mp),
      .ack_o(ack_o[22+b])
    );
    // f_arr — the MODULE-ARRAY carrier: ports hang off module_array
    ch38 i_ar [0:1] (
      .rd_i(pin_i.rd),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[18+2*b +: 2])
    );
  end

  assign sib_w = pin_i.rd;

endmodule

// top38 carries an INTERFACE PORT, so it cannot itself be a top-level module
// (slang rejects an unconnected interface port at the root).  This wrapper
// gives it a connection and keeps top38's own listing in the DEF view, which
// is the view under measurement.
module tb38 (
  input  q38::req_t   pin_i,
  input  q38::deep_t  deep_i,
  input  q38::req_t   uarr_i [0:1],
  output logic [31:0] ack_o
);
  ifc38 u_top_if ();
  top38 u_dut (
    .pin_i(pin_i),
    .deep_i(deep_i),
    .uarr_i(uarr_i),
    .ifp(u_top_if.mp),
    .ack_o(ack_o)
  );
endmodule
