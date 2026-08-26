// r10earl95 arm g3 -- THE POOL GRID.  Where a name has to LIVE for Surelog to
// substitute its value into an ELABORATED gen-scope cont_assign, crossed with
// the gen-scope DEPTH and the read CONTEXT.  MEASUREMENT ONLY.
package p95;
  localparam int unsigned PKGW = 3;
endpackage

module k95 #(
  parameter int unsigned W = 32
) (
  input  logic [7:0]   e_i,
  output logic [W-1:0] o_o
);
  localparam int unsigned MLOC = 4;
  localparam logic [63:0] TAB [8] =
    '{ 64'h9, 64'h12, 64'h21, 64'h41, 64'h8E, 64'h108, 64'h204, 64'h402 };
  logic [63:0] m_net;
  logic [63:0] q [0:31];

  // ---- module body control (no gen scope at all)
  assign q[0] = m_net[W-1:0];
  assign q[1] = m_net[MLOC-1:0];

  if (1) begin : d1
    localparam int unsigned D1 = 5;
    assign q[2] = m_net[W-1:0];                 // module PORT param   depth1
    assign q[3] = m_net[MLOC-1:0];              // module localparam   depth1
    assign q[4] = m_net[p95::PKGW-1:0];         // PACKAGE param       depth1
    assign q[5] = m_net[D1-1:0];                // OWN localparam      depth1
    assign q[6] = TAB[W-MLOC][W-1:0];           // head shape          depth1
    assign q[7] = {W{e_i[0]}};                  // replication count   depth1
    assign q[8] = m_net[W-2:0] | {W{e_i[1]}};   // plain operand ctx   depth1
    assign q[9] = m_net[MLOC+:4];               // ips base            depth1
    assign q[10] = {e_i, W[7:0]};               // concat element      depth1

    if (1) begin : d2
      localparam int unsigned D2 = 6;
      assign q[11] = m_net[W-1:0];              // module PORT param   depth2
      assign q[12] = m_net[MLOC-1:0];           // module localparam   depth2
      assign q[13] = m_net[p95::PKGW-1:0];      // PACKAGE param       depth2
      assign q[14] = m_net[D1-1:0];             // PARENT gen scope    depth2
      assign q[15] = m_net[D2-1:0];             // OWN localparam      depth2
      assign q[16] = TAB[W-MLOC][W-1:0];        // head shape          depth2
      assign q[17] = {W{e_i[0]}};               // replication count   depth2
      assign q[18] = m_net[W-2:0] | {W{e_i[1]}};// plain operand ctx   depth2
      assign q[19] = m_net[MLOC+:4];            // ips base            depth2
      assign q[20] = m_net[D2+:4];              // ips base OWN        depth2
      assign q[21] = m_net[D1+:4];              // ips base PARENT     depth2

      if (1) begin : d3
        assign q[22] = m_net[W-1:0];            // module PORT param   depth3
        assign q[23] = m_net[D1-1:0];           // GRANDPARENT gen sc  depth3
        assign q[24] = m_net[D2-1:0];           // PARENT gen scope    depth3
        assign q[25] = TAB[W-MLOC][W-1:0];      // head shape          depth3
      end
    end
  end

  // gen-for body (depth 1) and a nested gen-if inside it (depth 2)
  for (genvar gi = 0; gi < 2; gi++) begin : f1
    localparam int unsigned F1 = 7;
    assign q[26] = m_net[W-1:0];                // module PORT param   for-depth1
    assign q[27] = m_net[F1-1:0];               // OWN localparam      for-depth1
    if (1) begin : f2
      assign q[28] = m_net[W-1:0];              // module PORT param   for-depth2
      assign q[29] = m_net[F1-1:0];             // PARENT gen scope    for-depth2
      assign q[30] = m_net[gi+:4];              // the genvar          for-depth2
    end
  end

  assign o_o = q[0][W-1:0] ^ q[16][W-1:0] ^ q[25][W-1:0] ^ q[30][W-1:0];
endmodule

module topk95;
  logic [7:0] e;
  logic [4:0] o5;
  logic [5:0] o6;
  logic [7:0] o8;
  k95 #(.W(5)) u5 (.e_i(e), .o_o(o5));
  k95 #(.W(6)) u6 (.e_i(e), .o_o(o6));
  k95 #(.W(8)) u8 (.e_i(e), .o_o(o8));
endmodule
