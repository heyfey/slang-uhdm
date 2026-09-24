// r10vearl115 single-cell adversarial arm -- MEASUREMENT ONLY.
package pw12;
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

// THE FACE: a gen scope TWO levels deep in the SAME module (no module boundary
// between them) -- the consumer passes `genAbove` unchanged down
// `Gen_scope_arrays`, so the law must still fire.
module w12_deep2 #(parameter int M = 3) (
  input  logic        clk,
  input  pw12::h2d_t two_i [M],
  input  logic [7:0]  d_i,
  output logic        v_o
);
  for (genvar i = 0; i < M; i++) begin : gen_o
    for (genvar j = 0; j < 2; j++) begin : gen_i
      pw12::h2d_t w12_t;
      assign w12_t = '{ a_valid:  two_i[i].a_valid,
                        a_opcode: two_i[i].a_opcode,
                        a_data:   d_i };
    end
  end
  assign v_o = gen_o[0].gen_i[0].w12_t.a_valid ^ clk;
endmodule
