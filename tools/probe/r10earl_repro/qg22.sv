// qg22.sv — PASS 22.  The layer behind § genCaSysCallArgBinds22:
//   .. > multdiv_i > gen_scope > cont_assign ibex_multdiv_fast.sv:153:12
//     > sys_func_call '$unsigned' :153:29 > vpiTypespec
//   golden ref_typespec :0:0, ours <null>.
// Source: `assign mac_res_ext = $unsigned(mac_res_signed);` with both names
// MODULE-level signals read from inside a gen scope.  Rows below cross
// $signed vs $unsigned, module-level vs gen-local operand, whole-RHS call vs
// call under an operation, and the same shapes at module level.
module qg22_child (
    input  logic [33:0] a_i,
    output logic [34:0] oy1,
    output logic [34:0] oy2,
    output logic [34:0] oy3,
    output logic [34:0] oy4,
    output logic [34:0] oy5
);
  logic signed [34:0] ms;
  logic        [34:0] me;
  assign ms = a_i;
  assign oy5 = $unsigned(ms);            // G5 MODULE-level control

  if (1) begin : gen_b
    logic signed [34:0] gl;
    assign gl = a_i;
    assign oy1 = $unsigned(ms);          // G1 corpus shape, module operand
    assign oy2 = $signed(ms);            // G2 $signed twin
    assign oy3 = $unsigned(gl);          // G3 gen-local operand
    assign oy4 = $unsigned(ms) + 35'd1;  // G4 call under an operation
    assign me  = $unsigned(ms);          // G6 module LHS, module operand
  end
endmodule

module qg22 (
    input  logic [33:0] a_i,
    output logic [34:0] oy1,
    output logic [34:0] oy2,
    output logic [34:0] oy3,
    output logic [34:0] oy4,
    output logic [34:0] oy5
);
  qg22_child u_c (.a_i(a_i), .oy1(oy1), .oy2(oy2), .oy3(oy3), .oy4(oy4),
                  .oy5(oy5));
endmodule
