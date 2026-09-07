// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
// The package is r10earl115 arm p1's, verbatim in shape (the ENUM member is
// load-bearing: an all-`logic` packed struct port draws an unrelated
// `vpiNetType` head that stops the judge before it reaches a path element).
package pw8;
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
// ANY member of the enclosing InstanceBody.  Here the namesake is a PARAMETER, a kind r10vearl113's v6_name113 does not carry.
module w8_nsparam_child #(parameter int M = 3) (
  input  pw8::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        y_o
);
  localparam int ns_t = 7;   // a PARAMETER namesake
  for (genvar i = 0; i < M; i++) begin : gen_ns
    pw8::h2d_t ns_t;
    assign ns_t = '{ a_valid:  two_i[i].a_valid,
                     a_opcode: two_i[i].a_opcode,
                     a_data:   d_i };
  end
  assign y_o = gen_ns[0].ns_t.a_valid;
endmodule

module w8_nsparam #(parameter int M = 3) (
  input  logic        clk,
  input  pw8::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  logic y_c;
  w8_nsparam_child #(.M(M)) u_c (.two_i(two_i), .d_i(d_i), .y_o(y_c));
  assign v_o = y_c ^ clk;
endmodule
