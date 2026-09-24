// r10uvm80 arm c2 — the `automatic` KEYWORD applied to every BLOCK-LOCAL
// DECLARATION SHAPE our StmtEmit block loop has a separate factory for
// (scalar, packed vector, fixed unpacked array, queue, dynamic array,
// associative array, string, class handle, enum, struct), plus a MULTI-
// DECLARATOR declaration.  The question the arm answers is not "does the
// keyword work" (arm c1 settled that) but WHICH OBJECT of a multi-object
// declaration golden stamps: an array declaration mints an element variable AND
// an array_var, and a detector that assumes "the one in blockMap" would be
// guessing.
package q80;
  typedef enum {E0, E1} e80_t;
  typedef struct packed { logic [1:0] a; logic b; } s80_t;
  class k80;
    int f;
  endclass

  class c80b;
    int m_i;
    task t_kinds();
      begin
        automatic int          a_scal = 1;        // scalar
        automatic logic [3:0]  b_vec = 4'h5;      // packed vector
        automatic int          c_fix [3];         // fixed unpacked array
        automatic int          d_que [$];         // queue
        automatic int          e_dyn [];          // dynamic array
        automatic int          f_asc [string];    // associative array
        automatic string       g_str = "x";       // string
        automatic k80          h_cls = new();     // class handle, new init
        automatic e80_t        i_enum = E0;       // enum
        automatic s80_t        j_str2;            // packed struct
        automatic int          k_m1 = 1, k_m2 = 2;// MULTI-declarator
        static   int           l_stat [3];        // static kw + array (control)
        int                    m_plainq [$];      // no kw + queue (control)
        m_i = a_scal + int'(b_vec) + c_fix[0] + d_que.size() + e_dyn.size() +
              f_asc.size() + g_str.len() + h_cls.f + int'(i_enum) +
              int'(j_str2.b) + k_m1 + k_m2 + l_stat[0] + m_plainq.size();
      end
    endtask
  endclass
endpackage

module m80b;
  int mi;
  initial begin
    automatic int n_marr [2];       // module initial + array
    automatic int o_mq [$];         // module initial + queue
    mi = n_marr[0] + o_mq.size();
  end
endmodule
