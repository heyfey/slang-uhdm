// r10uvm80 VERIFIER arm v2 — WHICH VAR KIND carries the stamp, and does golden
// stamp them ALL?  The implementer's c2 measured 13 declaration kinds; this adds
// the ones it did not: real / shortreal / time / realtime / byte / shortint /
// longint / integer / bit / chandle / event, a UNION, a 2-D fixed array, an
// array OF struct, a queue OF struct, a dynamic array OF class handle, an
// associative array with an INT key, a typedef'd unpacked-array type (the
// dimensions come from the TYPEDEF, not the declarator), a packed struct, and a
// class handle with no `new()`.  Also two module-scope twins, and the c2
// controls repeated so this arm is self-contained.
package pv2;
  typedef enum int { EA = 0, EB = 1 } ev2_t;
  typedef struct { int a; byte b; } sv2_t;                 // unpacked struct
  typedef struct packed { logic [3:0] a; logic [3:0] b; } spk2_t;
  typedef union { int a; logic [31:0] b; } uv2_t;
  typedef int tdarr_t [4];                                  // dims on the TYPEDEF
  class kv2;
    int q;
  endclass

  class cv2;
    int m_i;
    task t_kinds();
      begin
        // ---- atoms golden may or may not stamp --------------------------
        automatic real       w_real   = 1.0;    // w1
        automatic shortreal  w_sreal  = 1.0;    // w2
        automatic realtime   w_rtime  = 1.0;    // w3
        automatic time       w_time   = 1;      // w4
        automatic byte       w_byte   = 1;      // w5
        automatic shortint   w_sint   = 1;      // w6
        automatic longint    w_lint   = 1;      // w7
        automatic integer    w_integ  = 1;      // w8
        automatic bit        w_bit    = 1;      // w9
        automatic bit [7:0]  w_bvec   = 8'h1;   // w10
        automatic logic signed [7:0] w_sgn = 8'h1; // w11 signed vector
        automatic chandle    w_chand;           // w12
        automatic string     w_str    = "x";    // w13
        // ---- aggregates --------------------------------------------------
        automatic sv2_t      w_struct;          // w14 unpacked struct
        automatic spk2_t     w_pstruct;         // w15 PACKED struct
        automatic uv2_t      w_union;           // w16 union
        automatic ev2_t      w_enum   = EA;     // w17
        automatic kv2        w_clsnew = new();  // w18 class handle WITH new()
        automatic kv2        w_clsnul;          // w19 class handle, NO new()
        // ---- arrays ------------------------------------------------------
        automatic int        w_arr2 [2][3];     // w20 2-D fixed unpacked
        automatic sv2_t      w_astr [2];        // w21 array OF struct
        automatic sv2_t      w_qstr [$];        // w22 queue OF struct
        automatic kv2        w_dcls [];         // w23 dynamic array OF class
        automatic int        w_aint [int];      // w24 assoc, INT key
        automatic int        w_aw   [*];        // w25 assoc, WILDCARD key
        automatic tdarr_t    w_tdarr;           // w26 dims from the TYPEDEF
        automatic int        w_qq [$][$];       // w27 queue of queue
        // ---- controls (no keyword / static) --------------------------------
        int    w_plain = 1;                     // w28 control
        static int w_stat = 1;                  // w29 control
        real   w_prreal = 1.0;                  // w30 control (real, no kw)
        sv2_t  w_pstructc;                      // w31 control (struct, no kw)
        int    w_parr [2];                      // w32 control (array, no kw)
        m_i = w_byte + w_bit + w_plain + w_stat + w_integ;
        m_i += w_struct.a + w_enum + w_arr2[0][0] + w_astr[0].a + w_tdarr[0];
        m_i += w_pstruct.a + w_union.a + w_aint[0] + w_pstructc.a + w_parr[0];
        m_i += int'(w_real) + int'(w_prreal) + w_str.len() + w_sgn + w_bvec;
        m_i += w_sint + w_lint + int'(w_time) + int'(w_sreal) + int'(w_rtime);
        if (w_clsnew != null) m_i++;
        if (w_clsnul == null) m_i++;
        if (w_chand == null) m_i++;
        w_qstr.push_back(w_struct);
        w_dcls = new[2];
        w_aw[3] = 1;
        w_qq = '{'{1}};
        m_i += w_qstr.size() + w_dcls.size() + w_aw.size() + w_qq.size();
      end
    endtask
  endclass
endpackage

module mv2;
  import pv2::*;
  int mi;
  initial begin
    // module-scope twins of the load-bearing kinds
    automatic real   z_real  = 1.0;             // w33
    automatic sv2_t  z_struct;                  // w34
    automatic int    z_arr2 [2][3];             // w35
    automatic int    z_que  [$];                // w36
    automatic string z_str   = "y";             // w37
    automatic ev2_t  z_enum  = EB;              // w38
    int              z_plain = 1;               // w39 control
    mi = int'(z_real) + z_struct.a + z_arr2[0][0] + z_plain + z_enum;
    z_que.push_back(1);
    mi += z_que.size() + z_str.len();
  end
endmodule
