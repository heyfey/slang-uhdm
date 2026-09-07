// r10vearl114 ARM v2 -- THE DECLARING-SCOPE AXIS (the fence's own axis) and
// the GENERATE-DEPTH axis.  Rows g1..g6 vary WHERE the root is declared;
// rows d1..d4 vary the generate construct the pattern sits in.
// MEASUREMENT ONLY.
`include "pv114.sv"
module v2_gen114 (output logic o);
  import pv114::*;
  vs_t m_arr [2];
  vs_t m_single;

  for (genvar i = 0; i < 2; i++) begin : g
    vs_t  gl_var;                  // g1: gen-local plain struct VAR
    wire  vs_t gl_net;             // g2: gen-local struct NET
    vs_t  gl_arr [2];              // g3: gen-local unpacked array
    assign gl_net = '{v:1'b0, op:VE0, d:8'h00};

    vs_t a1; assign a1 = '{v: gl_var.v,     op: gl_var.op,     d: gl_var.d};
    vs_t a2; assign a2 = '{v: gl_net.v,     op: gl_net.op,     d: gl_net.d};
    vs_t a3; assign a3 = '{v: gl_arr[i].v,  op: gl_arr[i].op,  d: gl_arr[i].d};
    vs_t a4; assign a4 = '{v: m_arr[i].v,   op: m_arr[i].op,   d: m_arr[i].d};

    for (genvar j = 0; j < 2; j++) begin : h
      // g4/g5: read the ENCLOSING gen block's local from a NESTED one
      vs_t b1; assign b1 = '{v: gl_var.v,   op: gl_var.op,   d: gl_var.d};
      vs_t b2; assign b2 = '{v: gl_net.v,   op: gl_net.op,   d: gl_net.d};
      // d1: DEPTH 2 with a module-scope root
      vs_t b3; assign b3 = '{v: m_arr[j].v, op: m_arr[j].op, d: m_arr[j].d};
    end
  end

  if (1) begin : gi                 // d2: GEN-IF
    vs_t c1; assign c1 = '{v: m_arr[0].v, op: m_arr[0].op, d: m_arr[0].d};
    vs_t c2; assign c2 = '{v: m_single.v, op: m_single.op, d: m_single.d};
  end

  localparam int SEL = 1;
  case (SEL)                        // d3: GEN-CASE
    1: begin : gc
      vs_t c3; assign c3 = '{v: m_arr[1].v, op: m_arr[1].op, d: m_arr[1].d};
    end
    default: begin : gcd
      vs_t c4; assign c4 = '{v: m_arr[0].v, op: m_arr[0].op, d: m_arr[0].d};
    end
  endcase

  // d4: MODULE SCOPE (the instance==nullptr half of the gate) -- MUST STAY BARE
  vs_t c5; assign c5 = '{v: m_arr[0].v, op: m_arr[0].op, d: m_arr[0].d};

  assign o = 1'b0;
endmodule
