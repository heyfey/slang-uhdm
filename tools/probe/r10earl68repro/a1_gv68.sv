// r10earl68 arm a1 — THE GENVAR-READ POSITION x DISTANCE GRID.
// Minimises prim_arbiter_tree's nested gen_tree / gen_level / gen_leafs /
// gen_assign shape: a genvar declared by a for-generate and read from inside
// 0..3 further generate blocks, in every position an ELAB gen-scope
// cont_assign can put it in.  MEASUREMENT ONLY.
module a1_gv68 #(
  parameter int unsigned NN = 4
) (
  input  logic [7:0] din,
  output logic [7:0] dout
);
  localparam int unsigned W = 4;
  logic [31:0][7:0] arr;
  logic [31:0][7:0] brr;
  logic [63:0] wide;
  logic [3:0]  nib;
  logic [7:0]  byt;
  logic [7:0]  net_d0, net_d1, net_d2, net_d3;

  // ---- distance 0: the read is in the genvar's OWN generate block ---------
  for (genvar i = 0; i < 3; i++) begin : g_d0
    assign arr[i]  = i;                 // whole Rhs, Lhs = bit_select
    assign net_d0  = i;                 // whole Rhs, Lhs = plain 8-bit net
  end

  // ---- distance 1 --------------------------------------------------------
  for (genvar i = 0; i < 3; i++) begin : g_d1
    if (i >= 0) begin : b1
      assign brr[i] = i;                // whole Rhs, distance 1
      assign net_d1 = i;
    end
  end

  // ---- distance 2 (the head's own distance) ------------------------------
  for (genvar i = 0; i < 3; i++) begin : g_d2
    if (i >= 0) begin : b1
      if (i < 3) begin : b2
        assign arr[i+8] = i;            // whole Rhs, distance 2
        assign net_d2   = i;
      end
    end
  end

  // ---- distance 3 --------------------------------------------------------
  for (genvar i = 0; i < 2; i++) begin : g_d3
    if (i >= 0) begin : b1
      if (i >= 0) begin : b2
        if (i >= 0) begin : b3
          assign arr[i+12] = i;         // whole Rhs, distance 3
          assign net_d3    = i;
        end
      end
    end
  end

  // ---- the POSITION grid at distance 0 -----------------------------------
  logic [7:0] p_op, p_cat, p_tern, p_idx, p_ips, p_ipsm, p_cast, p_lhsidx;
  logic [7:0] p_partl, p_wide, p_nib;
  for (genvar i = 1; i < 3; i++) begin : g_pos0
    assign p_op    = i + 1;             // operation Rhs, FULLY reducible
    assign p_cat   = {i[0], 1'b0};      // concat
    assign p_tern  = i ? din : ~din;    // ternary predicate (din = a net)
    assign p_idx   = arr[i];            // bit-select INDEX
    assign p_ips   = wide[i +: 8];      // indexed part-select BASE
    assign p_ipsm  = wide[i*2 +: 8];    // ips base, computed
    assign p_cast  = W'(i);             // cast
    assign arr[i+16] = din;             // Lhs bit-select index, Rhs = net
    assign p_partl = din + i;           // operation with a NET operand
    assign p_wide  = din[i];            // bit-select index of a net
  end

  // ---- the POSITION grid at distance 2 -----------------------------------
  logic [7:0] q_op, q_idx, q_ips, q_cat, q_bare;
  for (genvar i = 1; i < 3; i++) begin : g_pos2
    if (i >= 0) begin : b1
      if (i >= 0) begin : b2
        assign q_bare = i;
        assign q_op   = i + 1;
        assign q_idx  = arr[i];
        assign q_ips  = wide[i +: 8];
        assign q_cat  = {i[0], 1'b0};
      end
    end
  end

  // ---- nested for-generate: TWO genvars ----------------------------------
  logic [7:0] n_ij, n_i, n_j;
  for (genvar i = 0; i < 2; i++) begin : g_ni
    for (genvar j = 0; j < 2; j++) begin : g_nj
      assign n_ij = i + j;              // both genvars, fully reducible
      assign n_i  = i;                  // OUTER genvar, distance 1
      assign n_j  = j;                  // INNER genvar, distance 0
    end
  end

  // ---- localparam-of-genvar contrast --------------------------------------
  logic [7:0] l_bare, l_idx;
  for (genvar i = 0; i < 2; i++) begin : g_lp
    localparam int unsigned Pl = i + 1;
    if (i >= 0) begin : b1
      assign l_bare = Pl;               // localparam whole Rhs (earl64 family)
      assign l_idx  = arr[Pl];          // localparam bit-select idx (earl67)
    end
  end

  // ---- Lhs positions -------------------------------------------------------
  for (genvar i = 0; i < 2; i++) begin : g_lhs
    if (i >= 0) begin : b1
      assign arr[i+20] = din;           // Lhs bit-select INDEX at distance 1
      assign wide[i +: 8] = din;        // Lhs ips base at distance 1
    end
  end

  assign dout = arr[0] ^ brr[0] ^ net_d0 ^ net_d1 ^ net_d2 ^ net_d3 ^
                p_op ^ p_cat ^ p_tern ^ p_idx ^ p_ips ^ p_ipsm ^ p_cast ^
                p_partl ^ p_wide ^ q_bare ^ q_op ^ q_idx ^ q_ips ^ q_cat ^
                n_ij ^ n_i ^ n_j ^ l_bare ^ l_idx ^ nib ^ byt;
endmodule
