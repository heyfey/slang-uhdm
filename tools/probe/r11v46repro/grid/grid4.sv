// v11u46 ADVERSARIAL GRID-4 — signing-cast positions the implementer's
// grids 1-3 did NOT cover.  Every cell is legal SV; one cast per source line
// so the line:col key is unambiguous.
package p4v;
  parameter int unsigned QN = 6;
  typedef enum logic [3:0] {EA = 4'd1, EB = 4'd2} e4_t;
endpackage

module leaf4 #(parameter int unsigned W = 4) (input logic [7:0] a_i, output logic [7:0] y_o);
  assign y_o = a_i;
endmodule

module grid4
  import p4v::*;
#(
    parameter int unsigned N = 4
) (
    // AK: cast in a PORT packed dimension
    input  logic [unsigned'(3):0] pk_i,
    input  logic [7:0] in_i,
    output logic [7:0] out_o
);
  localparam int unsigned M = 3;
  logic [7:0] x, y;

  // AA: cast in a PROCEDURAL assignment (always_comb, def view)
  always_comb y = unsigned'(x);

  // AB: cast inside a FUNCTION BODY (the cfg_func_width_loop route)
  function automatic int unsigned fwid(input int unsigned v);
    fwid = unsigned'(v) + 1;
  endfunction

  // AC: cast inside a procedural FOR loop bound in an always block
  always_comb begin
    for (int k = 0; k < unsigned'(M); k++) x[k] = in_i[k];
  end

  // AD: cast applied to a CONCATENATION
  assign out_o[0] = |unsigned'({in_i[1], in_i[0]});

  // AE: NESTED casts
  assign out_o[1] = |unsigned'(signed'(in_i[2]));

  // AF: cast in an INSTANCE-ARRAY dimension
  logic [7:0] arrq [0:1];
  leaf4 #(.W(4)) u_arr [unsigned'(1):0] (.a_i(in_i), .y_o());

  // AG: cast in a TYPEDEF packed range
  typedef logic [unsigned'(M):0] t4_t;
  t4_t tsig;
  assign tsig = '0;

  // AH: cast in a STRUCT MEMBER range
  typedef struct packed {
    logic [unsigned'(M):0] f;
  } st4_t;
  st4_t ssig;
  assign ssig = '0;

  // AI: cast in an ENUM member value
  typedef enum logic [3:0] {EC = unsigned'(3), ED = 4'd4} en4_t;
  en4_t esig;
  assign esig = EC;

  // AL: cast as a REPLICATION count
  assign out_o[2] = |{unsigned'(2){1'b1}};

  // AQ: cast in a MODULE-LEVEL continuous assign rhs index
  assign out_o[3] = in_i[unsigned'(M)];

  // AR: cast over a QUALIFIED package parameter, module level
  assign out_o[4] = in_i[unsigned'(p4v::QN)>>1];

  // AM: cast in a gen-CASE ITEM expression
  case (M)
    unsigned'(3): begin : g_am
      assign out_o[5] = in_i[5];
    end
    default: begin : g_amd
      assign out_o[5] = in_i[6];
    end
  endcase

  // AN: cast in a NESTED gen_for condition
  for (genvar n1 = 0; unsigned'(n1) < N; n1++) begin : g_n1
    for (genvar n2 = 0; unsigned'(n2) < unsigned'(n1) + 1; n2++) begin : g_n2
      assign out_o[6] = in_i[6];
    end
  end

  // AU: cast in an UNPACKED dimension bound of a gen-block net
  for (genvar u1 = 0; u1 < N; u1++) begin : g_u1
    logic [7:0] ubuf [unsigned'(2)];
  end

  // AS: cast in a gen_if ELSE-IF chain condition
  if (N > 8) begin : g_as0
    assign out_o[7] = in_i[0];
  end
  else if (unsigned'(M) > 1) begin : g_as1
    assign out_o[7] = in_i[1];
  end
  else begin : g_as2
    assign out_o[7] = in_i[2];
  end
endmodule

module grid4top (input logic [3:0] p_i, input logic [7:0] i_i, output logic [7:0] o_o);
  grid4 #(.N(4)) u0 (.pk_i(p_i), .in_i(i_i), .out_o(o_o));
endmodule
