// r10uvm43 arm t60b — the KIND GATE, measured where OUR emitter can be seen.
//
// t60a put every declaration at PACKAGE scope and that made HALF of it
// unreadable: our emitter drops a package-level fixed unpacked array variable
// entirely (`t_int e_int[4];` in a package emits no variable at all, measured)
// and rejects a class PROPERTY whose type is an unpacked array over a
// non-vector typedef ("class property type: FixedSizeUnpackedArrayType").  So
// the golden half of t60a states the law and this arm states OUR half, at
// MODULE scope where both tools emit the whole shape.
//
// Positions per typedef: fixed unpacked array ELEMENT, associative INDEX,
// dynamic array, queue.  Homes: module-local typedef AND package typedef used
// from the module (the package home is the one whose listing object is spelled
// `pkc::name`, i.e. the only one where the clone law is a NAME difference).
package pk61;
  typedef int          p_int;
  typedef byte         p_byte;
  typedef shortint     p_sint;
  typedef longint      p_lint;
  typedef integer      p_integer;
  typedef int unsigned p_uint;
  typedef time         p_time;
  typedef string       p_str;
  typedef bit [7:0]    p_bit8;      // the decoded case
  typedef logic [3:0]  p_log4;
  typedef p_bit8       p_chain;     // a typedef OF a typedef
  typedef enum { F0, F1 } p_enum;   // excluded by the law today
  typedef struct packed { bit a; bit b; } p_pstr;
endpackage

module dut61;
  import pk61::*;

  typedef int       m_int;
  typedef byte      m_byte;
  typedef bit [7:0] m_bit8;
  typedef m_bit8    m_chain;

  // ---- module-local typedefs, every container position -------------------
  m_int    l_ifix[4];
  int      l_imap[m_int];
  m_int    l_idyn[];
  m_int    l_iq[$];
  m_byte   l_bfix[4];
  int      l_bmap[m_byte];
  m_bit8   l_vfix[4];
  int      l_vmap[m_bit8];
  m_chain  l_cfix[4];
  int      l_cmap[m_chain];

  // ---- the PACKAGE typedefs, where the clone law changes the NAME --------
  p_int     q_ifix[4];
  int       q_imap[p_int];
  p_int     q_idyn[];
  p_int     q_iq[$];
  p_byte    q_bfix[4];
  int       q_bmap[p_byte];
  p_sint    q_sfix[4];
  p_lint    q_lfix[4];
  p_integer q_gfix[4];
  p_uint    q_ufix[4];
  p_time    q_tfix[4];
  p_str     q_strfix[4];
  int       q_strmap[p_str];
  p_bit8    q_vfix[4];
  int       q_vmap[p_bit8];
  p_log4    q_gl4fix[4];
  p_chain   q_cfix[4];
  int       q_cmap[p_chain];
  p_enum    q_efix[4];
  int       q_emap[p_enum];
  p_pstr    q_pfix[4];

  // ---- plain scalars, which must not move --------------------------------
  m_int  s_mint;
  p_int  s_pint;
  p_bit8 s_pbit8;

  initial begin
    l_ifix[0] = 1;
    l_imap[2] = 3;
    q_ifix[0] = 4;
    q_vfix[0] = 8'h5;
    s_mint    = 6;
  end
endmodule
