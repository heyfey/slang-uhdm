// pp18.sv -- r10earl18 witness for the DEF-VIEW GEN-BLOCK `pkg::PARAM` READ.
// work@prim_present / work@prim_prince bisect to
//   gen_for > named_begin > gen_if_else > named_begin > cont_assign >
//   func_call > arg ref_obj 'prim_cipher_pkg::PRESENT_SBOX4' >
//   vpiActual parameter > vpiTypespec > logic_typespec > vpiInstance
// and that last pointer is the DEFINITION package for us, the ELABORATED one
// for golden -- § pkgRefActualTopParam16 in a place its walk never reaches.
// An UNPACKED-ARRAY parameter is used so the read stays an unfolded ref_obj.
package pp18p;
  parameter logic [7:0] TBL [4] = '{8'h1, 8'h2, 8'h3, 8'h4};
  parameter int WID = 8;
  function automatic logic [7:0] pick(logic [7:0] t [4], logic [1:0] i);
    pick = t[i];
  endfunction
endpackage

module pp18 #(
  parameter int W = 8
) (
  input  logic [1:0] i0,
  output logic [7:0] oA,
  output logic [7:0] oB
);
  for (genvar k = 0; k < 1; k++) begin : gen_l
    if (W == 8) begin : gen_a
      // the prim_present shape: a gen-scope cont_assign whose rhs is a
      // qualified package call taking a qualified package parameter.
      assign oA = pp18p::pick(pp18p::TBL, i0);
    end else begin : gen_b
      assign oA = '0;
    end
  end
  // module-body control: the same read outside any generate block.
  assign oB = pp18p::pick(pp18p::TBL, i0);
endmodule
