// r10earl8 witness tk — ELAB gen_scope VARIABLE population.
// TopModules heads (2 of the 8, and the first witness this cluster has ever
// had):
//   work@prim_present  failLhs logic_var 'data_state_xor'  prim_present.sv:52:27
//                      failRhs <null>   (r=1, under gen_scope_array
//                                        'gen_round[0]')
//   work@prim_prince   failLhs logic_var 'data_state_round' prim_prince.sv:86:27
//                      failRhs <null>   (r=1, gen_scope_array 'gen_fwd_pass[1]')
// Both are a plain `logic [W-1:0] v;` declared DIRECTLY in a genvar-for body
// that ALSO contains a nested if-generate.
module tk #(
  parameter int DataWidth = 8,
  parameter int NumRounds = 2,
  parameter bit Wide      = 1'b1
) (
  input  logic [DataWidth-1:0] d_i,
  output logic [DataWidth-1:0] d_o
);

  logic [NumRounds:0][DataWidth-1:0] st;
  assign st[0] = d_i;

  // A — one declarator + a nested if-generate (the prim_prince shape)
  for (genvar k = 0; k < NumRounds; k++) begin : gen_a
    logic [DataWidth-1:0] va_round;
    if (Wide) begin : gen_a_w
      always_comb begin : p_a_w
        va_round = st[k] ^ {DataWidth{1'b1}};
      end
    end else begin : gen_a_n
      always_comb begin : p_a_n
        va_round = st[k];
      end
    end
    assign st[k+1] = va_round;
  end

  // B — TWO declarators on one line + a nested if-generate
  //     (the prim_present shape)
  for (genvar k = 0; k < NumRounds; k++) begin : gen_b
    logic [DataWidth-1:0] vb_xor, vb_sbox;
    assign vb_xor = st[k];
    if (Wide) begin : gen_b_w
      assign vb_sbox = ~vb_xor;
    end else begin : gen_b_n
      assign vb_sbox = vb_xor;
    end
  end

  // C — control: the same declaration with NO nested generate
  for (genvar k = 0; k < NumRounds; k++) begin : gen_c
    logic [DataWidth-1:0] vc;
    assign vc = st[k];
  end

  // D — the u2r MemoryInGenblock DISTINGUISHER, split into its two
  //     candidate causes:
  //       D1  UNPACKED-ARRAY gen local, whole-ref RHS, SAME scope
  //       D2  SCALAR gen local of an ANCESTOR gen scope, whole-ref RHS
  //     (MemoryInGenblock is unpacked-array + ancestor + RHS, and golden
  //      leaves it UNBOUND; tk row B proved ancestor + LHS binds and row A
  //      proved same-scope + RHS binds.)
  logic [DataWidth-1:0] arr_o [2];
  logic [DataWidth-1:0] sc_o;
  for (genvar k = 0; k < 1; k++) begin : gen_d
    logic [DataWidth-1:0] vd_arr [2];
    logic [DataWidth-1:0] vd_sc;
    assign arr_o = vd_arr;                 // D1
    if (Wide) begin : gen_d_w
      assign sc_o = vd_sc;                 // D2
    end
  end

  assign d_o = st[NumRounds];

endmodule
