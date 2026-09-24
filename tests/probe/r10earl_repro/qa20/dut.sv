// qa20.sv — PASS 20 witness for the top_earlgrey PAIR (def:work@top_earlgrey
// and work@top_earlgrey, both r=-1, one object).  The bisect walks
//   work@top_earlgrey > u_rv_core_ibex > u_core > if_stage_i
//     > port 'instr_pmp_err_i' > bit_select 'pmp_req_err'
//       > vpiIndex constant {ct=9 sz=32 dec=0} > vpiTypespec
// where golden has NO ref_typespec on the folded index constant and we stamp
// one.  The index is `PMP_I`, an `int unsigned` PACKAGE parameter read through
// a wildcard import, inside a PORT CONNECTION expression
// (ibex_core.sv:394:47, `.instr_pmp_err_i ( pmp_req_err[PMP_I] )`).
package qa20_pkg;
  parameter int unsigned PI = 0;
endpackage

module qa20_child (
    input  logic e,
    output logic y
);
  assign y = e;
endmodule

module qa20
  import qa20_pkg::*;
(
    input  logic [3:0] v,
    output logic       o1,
    output logic       o2
);

  qa20_child u_bare (.e(v[PI]),           .y(o1));  // unqualified (wildcard)
  qa20_child u_qual (.e(v[qa20_pkg::PI]), .y(o2));  // written qualified

endmodule
