// v11u79 q1 — the STRUCT MEMBER TEST's unmeasured faces.  pkgStructAllLogic79
// keeps a struct in the NET vector only when every member's canonical leaf is
// a four-state ScalarType (or a nested struct that passes the same test).
// These are the member kinds the implementer's grid never spelled.
package q1;
  typedef union  packed { logic [7:0] a; logic [7:0] b; } uun_t;
  typedef struct packed { logic [7:0] a; uun_t b; }       s_memunion;
  s_memunion                                   m_union;    // a UNION member
  typedef struct packed { logic [7:0] a; logic [3:0] b; } inner_t;
  typedef struct packed { inner_t a; logic [7:0] b; }     s_memnest;
  s_memnest                                    m_nest;     // nested all-logic
  typedef struct packed { int x; }                        innerint_t;
  typedef struct packed { innerint_t a; logic [7:0] b; }  s_memnestint;
  s_memnestint                                 m_nestint;  // nested WITH int
  typedef struct packed { inner_t [1:0] a; logic b; }     s_memparrst;
  s_memparrst                                  m_parrst;   // packed ARRAY of struct
  typedef struct packed { reg [7:0] a; reg b; }           s_memreg;
  s_memreg                                     m_reg;      // reg members
  typedef struct packed { logic signed [7:0] a; logic b; } s_memsigned;
  s_memsigned                                  m_signed;   // SIGNED logic member
  typedef struct { logic [7:0] a [0:1]; logic b; }        s_memuarr;
  s_memuarr                                    m_uarr;     // UNPACKED array member
  typedef struct packed { logic a; }                      s_one;
  s_one                                        m_one;      // a single member
  typedef struct packed { bit [7:0] a; logic b; }         s_membit;
  s_membit                                     m_bit;      // a BIT member
endpackage

module dut (output logic [31:0] o);
  import q1::*;
  assign o = {20'd0, m_union} ^ {20'd0, m_nest} ^ {24'd0, m_nestint}
           ^ {7'd0, m_parrst} ^ {23'd0, m_reg} ^ {23'd0, m_signed}
           ^ {31'd0, m_one} ^ {23'd0, m_bit};
endmodule
