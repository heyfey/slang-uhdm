// r10v112 arm v6 -- THE CALL-NESTING and CAST faces inside a pattern member
// value, the cells the fence's arithmetic (`callArgDepth - sysCallArgDepth22`)
// has to get right.  MEASUREMENT ONLY.
package pv6_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v6_call2112 #(parameter int M = 3) (
  input  pv6_112::h2d_t tl_h_i [M],
  output logic [7:0]    z_o
);
  function automatic logic [7:0] f8(input logic [7:0] x);
    return x ^ 8'h5a;
  endfunction

  for (genvar i = 0; i < M; i++) begin : gen_v6
    pv6_112::h2d_t j1, j2, j3, j4, j5;

    // j1  a SYSTEM call INSIDE a USER call argument
    assign j1 = '{ a_valid: 1'b0, a_opcode: 3'b0,
                   a_data:  f8($unsigned(tl_h_i[i].a_data)) };

    // j2  a USER call INSIDE a SYSTEM call argument
    assign j2 = '{ a_valid: 1'b0, a_opcode: 3'b0,
                   a_data:  $unsigned(f8(tl_h_i[i].a_data)) };

    // j3  a SYSTEM call inside a SYSTEM call
    assign j3 = '{ a_valid: 1'b0, a_opcode: 3'b0,
                   a_data:  $unsigned($signed(tl_h_i[i].a_data)) };

    // j4  a CAST of the path inside a pattern member value
    assign j4 = '{ a_valid: 1'b0, a_opcode: 3'b0,
                   a_data:  8'(tl_h_i[i].a_data) };

    // j5  a USER call argument that is an OPERATION over the path
    assign j5 = '{ a_valid: 1'b0, a_opcode: 3'b0,
                   a_data:  f8(tl_h_i[i].a_data | 8'h1) };

    // MUST STAY: a plain pattern member beside them all
    assign z_o = tl_h_i[i].a_data;
  end
endmodule
