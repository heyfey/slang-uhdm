// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw11;
  typedef enum logic [2:0] { OpA = 3'h0, OpB = 3'h4 } op_e;
  typedef struct packed {
    logic       a_valid;
    op_e        a_opcode;
    logic [7:0] a_data;
  } h2d_t;
  typedef struct packed {
    h2d_t       lo;
    logic [3:0] hi;
  } two_t;
endpackage

// THE FACE: r10earl115's namesake fence is `Scope::find(name)`, which answers
// ANY member of the enclosing InstanceBody.  Here there is NO namesake in the child or its parent; an unrelated SIBLING module owns the name and must NOT fence the law.
module w11_nssib_child #(parameter int M = 3) (
  input  pw11::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  // NO namesake in this module -- the only `ns_t` is in an unrelated sibling.
  for (genvar i = 0; i < M; i++) begin : gen_ns
    pw11::h2d_t ns_t;
    assign ns_t = '{ a_valid:  two_i[i].a_valid,
                     a_opcode: two_i[i].a_opcode,
                     a_data:   d_i };
  end
  assign y_o = gen_ns[0].ns_t.a_valid;
endmodule

module w11_sib #(parameter int M = 3) (
  input  pw11::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  pw11::h2d_t ns_t;
  assign ns_t = '{ a_valid:  two_i[0].a_valid,
                   a_opcode: two_i[0].a_opcode,
                   a_data:   d_i };
  assign y_o = ns_t.a_valid;
endmodule

module w11_nssib #(parameter int M = 3) (
  input  logic        clk,
  input  pw11::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  logic y_c;
  w11_nssib_child #(.M(M)) u_c (.two_i(two_i), .d_i(d_i), .y_o(y_c));
  logic y_s;
  w11_sib #(.M(M)) u_s (.two_i(two_i), .d_i(d_i), .y_o(y_s));
  assign v_o = y_c ^ y_s ^ clk;
endmodule
