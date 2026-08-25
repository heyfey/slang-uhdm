// r10v126 arm A - SIGNING.  The implementer's four grids carry NOT ONE signing
// variant, yet the patch sets VpiSigned from slang's `leaf->isSigned()` on six
// typespec classes and Surelog's `time` arm ignores signing entirely.
// Every atom keyword x {bare, signed, unsigned}, in the head's own home.
package pk_sgn126v;
  class Signer126v;
    virtual task run();
      byte              b_bare126v  [3];
      byte     signed   b_sgn126v   [4];
      byte     unsigned b_uns126v   [5];
      shortint          h_bare126v  [6];
      shortint signed   h_sgn126v   [7];
      shortint unsigned h_uns126v   [2];
      int               i_bare126v  [8];
      int      signed   i_sgn126v   [9];
      int      unsigned i_uns126v   [3];
      longint           l_bare126v  [4];
      longint  signed   l_sgn126v   [5];
      longint  unsigned l_uns126v   [6];
      integer           g_bare126v  [7];
      integer  signed   g_sgn126v   [2];
      integer  unsigned g_uns126v   [8];
      time              t_bare126v  [9];
      time     signed   t_sgn126v   [3];
      time     unsigned t_uns126v   [4];
      bit               k_bare126v  [5];
      bit      signed   k_sgn126v   [6];
      bit  signed [5:0] k_sgnv126v  [7];
      logic             q_bare126v  [2];
      logic    signed   q_sgn126v   [8];
      logic signed[6:0] q_sgnv126v  [9];
      reg      signed   r_sgn126v   [4];
      b_bare126v[0]=8'd1; b_sgn126v[1]=8'd2; b_uns126v[2]=8'd3;
      h_bare126v[3]=16'd1; h_sgn126v[4]=16'd2; h_uns126v[1]=16'd3;
      i_bare126v[5]=1; i_sgn126v[6]=2; i_uns126v[2]=3;
      l_bare126v[3]=64'd1; l_sgn126v[4]=64'd2; l_uns126v[5]=64'd3;
      g_bare126v[6]=1; g_sgn126v[1]=2; g_uns126v[7]=3;
      t_bare126v[8]=1; t_sgn126v[2]=2; t_uns126v[3]=3;
      k_bare126v[4]=1'b1; k_sgn126v[5]=1'b0; k_sgnv126v[6]=6'd5;
      q_bare126v[1]=1'b1; q_sgn126v[7]=1'b0; q_sgnv126v[8]=7'd9;
      r_sgn126v[3]=1'b1;
    endtask
  endclass
endpackage
