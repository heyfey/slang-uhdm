// r10uvm61 VERIFIER ARM v4_type — the TYPE-SHAPE axis of the VALUE rule.
// c1/c4 measured: packed vector, int, bit, packed struct, enum, typedef alias,
// fixed unpacked array, string, real, class handle, queue.  The predicate's
// value arm is
//     isIntegral()                       -> getBitWidth()
//     isUnpackedArray() && isFixedSize() -> getBitstreamWidth()
//     else                                  REFUSE
// so every OTHER aggregate is an unmeasured cell -- and each one is a place a
// wrong constant could be emitted, or a fold could be missed.
package v4_pkg;
  typedef struct { logic [3:0] a; logic [2:0] b; } ust_t;   // UNPACKED struct
  typedef union packed { logic [7:0] a; logic [7:0] b; } pun_t;
  typedef union { logic [7:0] a; logic [15:0] b; } uun_t;   // UNPACKED union
  typedef enum { EA, EB, EC } noBase_t;                     // enum, no base
  typedef logic [3:0][7:0] p2_t;                            // packed 2-D

  class ty_c;
    ust_t          m_ust;      // R1  unpacked struct        (7 bits)
    pun_t          m_pun;      // R2  packed union           (8)
    uun_t          m_uun;      // R3  unpacked union
    noBase_t       m_nb;       // R4  enum with no base      (32)
    p2_t           m_p2;       // R5  packed 2-D             (32)
    logic [1:0]    m_2d[2][3]; // R6  fixed unpacked 2-D     (12)
    logic [1:0]    m_dyn[];    // R7  DYNAMIC array
    logic [1:0]    m_aa[string];// R8 ASSOCIATIVE array
    ust_t          m_ustarr[2];// R9  fixed unpacked array of unpacked struct
    // R10 chandle / R11 event REMOVED: slang rejects "invalid argument type
    //     'chandle'/'event' to system function" -- the cells CANNOT EXIST.
    time           m_tm;       // R12 time                   (64)
    shortreal      m_sr;       // R13 shortreal
    realtime       m_rt;       // R14 realtime
    byte  signed   m_bs;       // R15 signed byte            (8)
    bit   [0:0]    m_one;      // R16 1-bit packed range     (1)
    integer        m_ig;       // R17 integer                (32)
    logic          m_l;        // R18 bare logic             (1)
    logic [3:0]    m_fix;      // control
    function void r1(ref int o);
      o = $bits(m_ust);
      o = $bits(m_pun);
      o = $bits(m_uun);
      o = $bits(m_nb);
      o = $bits(m_p2);
      o = $bits(m_2d);
      o = $bits(m_dyn);
      o = $bits(m_aa);
      o = $bits(m_ustarr);
      o = $bits(m_tm);
      o = $bits(m_sr);
      o = $bits(m_rt);
      o = $bits(m_bs);
      o = $bits(m_one);
      o = $bits(m_ig);
      o = $bits(m_l);
      o = $bits(m_fix);
    endfunction
  endclass
endpackage

module v4_top;
  import v4_pkg::*;
  int o;
  initial begin
    ty_c a = new();
    a.r1(o);
  end
endmodule
