// r10uvm73 VERIFIER arm v4 — the NEGATED-integer operand's size on a degraded
// property, the twin of v3.  The patch hardcodes 64 there too.
package p1;
  class holder;
    typedef int        i_t;
    typedef bit [95:0] w_t;
    typedef bit [3:0]  n_t;
  endclass
  class negee;
    holder::i_t c_n_uns   = -1;      // unsized
    holder::i_t c_n_sz8   = -8'd1;   // SIZED 8, 32-bit property
    holder::w_t c_n_sz4   = -4'd1;   // SIZED 4, 96-bit property
    holder::n_t c_n_uns4  = -1;      // unsized, 4-bit property
  endclass
  class negctl;
    typedef int        i_t;
    typedef bit [95:0] w_t;
    typedef bit [3:0]  n_t;
    i_t k_n_uns  = -1;
    i_t k_n_sz8  = -8'd1;
    w_t k_n_sz4  = -4'd1;
    n_t k_n_uns4 = -1;
  endclass
endpackage
module top; p1::negee n; p1::negctl k; initial begin n=new(); k=new(); end endmodule
