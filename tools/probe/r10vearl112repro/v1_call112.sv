// r10v112 arm v1 -- THE CALL-ARGUMENT / OPERATION FACES INSIDE A PATTERN.
// MEASUREMENT ONLY.
//
// r10earl112's gate has NO `callArgDepth - sysCallArgDepth22 == 0` fence,
// while its own neighbours § genLpBitSelIdxOneHopFold67 and
// § connBitSelIdxModParamFold81 both carry one (earl67 measured golden KEEPING
// an unbound ref_obj at a gen-scope read inside a USER tf_call argument list
// while folding the same read one operand to its left).  This arm asks whether
// a pattern member value that is a USER call argument, a SYSTEM call argument,
// a concatenation, a replication or a nested operation folds on golden.
package pv1_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v1_call112 #(parameter int M = 3) (
  input  pv1_112::h2d_t tl_h_i [M],
  output logic [7:0]    z_o,
  output logic [7:0]    y_o
);
  function automatic logic [7:0] f8(input logic [7:0] x);
    return x ^ 8'h5a;
  endfunction

  for (genvar i = 0; i < M; i++) begin : gen_v1
    pv1_112::h2d_t k1, k2, k3, k4, k5;

    // k1  a USER function call ARGUMENT inside a pattern member value
    assign k1 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_opcode: 3'b0,
                   a_data:   f8(tl_h_i[i].a_data) };

    // k2  a SYSTEM call argument inside a pattern member value
    assign k2 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_opcode: 3'b0,
                   a_data:   $unsigned(tl_h_i[i].a_data) };

    // k3  a CONCATENATION and a REPLICATION inside a pattern member value
    assign k3 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_opcode: 3'b0,
                   a_data:   {2{tl_h_i[i].a_data[3:0]}} };

    // k4  a nested TERNARY inside a pattern member value
    assign k4 = '{ a_valid:  tl_h_i[i].a_valid,
                   a_opcode: 3'b0,
                   a_data:   tl_h_i[i].a_valid ? tl_h_i[i].a_data : 8'h0 };

    // k5  a USER call whose argument is itself a pattern-free operation, with
    //     a nested user call -- the earl67 "call inside a call" face
    assign k5 = '{ a_valid:  1'b0,
                   a_opcode: 3'b0,
                   a_data:   f8(f8(tl_h_i[i].a_data)) };

    // MUST STAY: the same user call OUTSIDE any pattern
    assign z_o = f8(tl_h_i[i].a_data);
    // MUST STAY: the same system call OUTSIDE any pattern
    assign y_o = $unsigned(tl_h_i[i].a_data);
  end
endmodule
