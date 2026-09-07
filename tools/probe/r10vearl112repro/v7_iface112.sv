// r10v112 arm v7 -- THE INTERFACE-ARRAY face.  MEASUREMENT ONLY.
// The interface cluster is 21% of the DIFF corpus; a pattern member value that
// reads an interface-array element through a genvar index is the shape this
// law could reach without any arm noticing.
interface iface112 ();
  logic       a_valid;
  logic [2:0] a_opcode;
  logic [7:0] a_data;
endinterface

package pv7_112;
  typedef struct packed {
    logic       a_valid;
    logic [2:0] a_opcode;
    logic [7:0] a_data;
  } h2d_t;
endpackage

module v7_iface112 #(parameter int M = 3) (
  output pv7_112::h2d_t o_o
);
  iface112 ifs [M] ();

  for (genvar i = 0; i < M; i++) begin : gen_if
    pv7_112::h2d_t t1;
    // t1  an INTERFACE-ARRAY element read inside a pattern member value
    assign t1 = '{ a_valid:  ifs[i].a_valid,
                   a_opcode: ifs[i].a_opcode,
                   a_data:   ifs[i].a_data };
    // MUST STAY: the same read in a PLAIN cont_assign
    wire w1;
    assign w1 = ifs[i].a_valid;
  end

  assign o_o = gen_if[0].t1;
endmodule
