// r10earl112 arm g1 -- THE HEAD SHAPE and the RENDER-CONTEXT matrix at
// generate depth 1.  MEASUREMENT ONLY.
//
// The corpus head is tlul_socket_m1.sv:108-118
//     assign hreq_fifo_i = '{ a_valid: tl_h_i[i].a_valid, ... };
// inside `for (genvar i...) begin : gen_host_fifo`, where golden's hier_path
// NAME reads `tl_h_i[0].a_valid` while ours reads `tl_h_i[i].a_valid` -- and
// three lines up, in a PLAIN cont_assign, golden SPELLS the same genvar
// (earl110's law).  Every cell below is the same path in a different
// syntactic carrier, so the axis is isolated to the carrier alone.
package p112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module sink112 (input logic clk, input logic [7:0] d);
endmodule

module g1_head112 #(parameter int M = 3) (
  input  logic                clk,
  input  p112::h2d_t          tl_h_i [M],
  output logic [M-1:0]        v_o,
  output logic [M-1:0]        w_o,
  output logic [M-1:0]        x_o,
  output logic [7:0]          y_o
);
  for (genvar i = 0; i < M; i++) begin : gen_host
    p112::h2d_t c1_keyed;
    p112::h2d_t c2_pos;
    logic [7:0] c6_cat;

    // c1  KEYED assignment-pattern member value -- THE HEAD SHAPE
    assign c1_keyed = '{ a_valid:  tl_h_i[i].a_valid,
                         a_opcode: tl_h_i[i].a_opcode,
                         a_data:   tl_h_i[i].a_data };

    // c2  POSITIONAL assignment-pattern element
    assign c2_pos = '{ tl_h_i[i].a_valid, tl_h_i[i].a_opcode,
                       tl_h_i[i].a_data };

    // c3  PLAIN cont_assign RHS -- the negative control (earl110's site)
    assign v_o[i] = tl_h_i[i].a_valid;

    // c4  BINARY-OPERATION operand in a cont_assign
    assign w_o[i] = tl_h_i[i].a_valid & tl_h_i[i].a_opcode[0];

    // c5  TERNARY arm in a cont_assign
    assign x_o[i] = tl_h_i[i].a_valid ? tl_h_i[i].a_opcode[1] : 1'b0;

    // c6  CONCATENATION operand
    assign c6_cat = { tl_h_i[i].a_opcode, tl_h_i[i].a_valid,
                      tl_h_i[i].a_data[3:0] };

    // c7  PORT high_conn of a child instance
    sink112 u_sink (.clk(clk), .d(tl_h_i[i].a_data));
  end

  assign y_o = tl_h_i[0].a_data;
endmodule
