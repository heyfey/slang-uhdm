// v11u46 verifier micro-probe: what does golden put in vpiParent for the RHS of
// a def-view gen_for INIT, by RHS kind?  (constant / ref_obj / operation /
// sys_func_call / func_call)
package p7v;
  parameter int unsigned PP = 2;
endpackage

module cell7
  import p7v::*;
#(
    parameter int unsigned NC = 6
) (
    input logic [7:0] in_i, output logic [7:0] out_o
);
  localparam int unsigned MM = 1;

  // CA: init is a literal CONSTANT
  for (genvar ca = 0; ca < NC; ca++) begin : g_ca
    assign out_o[0] = in_i[0];
  end

  // CB: init is a bare REF (module localparam)
  for (genvar cb = MM; cb < NC; cb++) begin : g_cb
    assign out_o[1] = in_i[1];
  end

  // CC: init is an OPERATION
  for (genvar cc = MM + 1; cc < NC; cc++) begin : g_cc
    assign out_o[2] = in_i[2];
  end

  // CD: init is a PACKAGE-parameter read (the landed fold)
  for (genvar cd = PP; cd < NC; cd++) begin : g_cd
    assign out_o[3] = in_i[3];
  end

  // CE: init is an explicit SYSTEM CALL
  for (genvar ce = $unsigned(MM); ce < NC; ce++) begin : g_ce
    assign out_o[4] = in_i[4];
  end

  // CF: init is a SIGNING CAST
  for (genvar cf = unsigned'(MM); cf < NC; cf++) begin : g_cf
    assign out_o[5] = in_i[5];
  end

  // CG: init is an operation CONTAINING a signing cast
  for (genvar cg = unsigned'(MM) + 1; cg < NC; cg++) begin : g_cg
    assign out_o[6] = in_i[6];
  end
endmodule

module grid7 (input logic [7:0] i_i, output logic [7:0] o_o);
  cell7 #(.NC(6)) u (.in_i(i_i), .out_o(o_o));
endmodule
