// r10uvm44 arm t61a — THE TYPESPEC-LISTING POPULATION, one typedef per NON-
// AGGREGATE base kind, at MODULE scope and at PACKAGE scope, so neither half
// of the law is inferred.  Pass 43 ranked "the three missing listing objects"
// first BY REACH; t60b showed the deficit for `int`/`byte` at module scope and
// `string` at package scope, but only for those three spellings.  A law that
// only ever saw one spelling has an unmeasured half, so this arm carries EVERY
// spelling that canonicalises away from ScalarType/PackedArrayType: the integer
// atoms, `string`, `real`/`shortreal`, `chandle`, `event`, plus a CHAINED atom
// typedef and an atom typedef with NO USER AT ALL (the population question is
// whether golden lists a typedef nobody references).
package pk62;
  typedef int          q_int;
  typedef int unsigned q_uint;
  typedef byte         q_byte;
  typedef shortint     q_sint;
  typedef longint      q_lint;
  typedef integer      q_integer;
  typedef time         q_time;
  typedef string       q_str;
  typedef real         q_real;
  typedef shortreal    q_sreal;
  typedef chandle      q_chandle;
  typedef event        q_event;
  typedef q_int        q_chain;    // a typedef OF an atom typedef
  typedef byte         q_unused;   // NO user anywhere
  typedef bit [7:0]    q_bit8;     // the already-supported control

  q_int    pv_int;
  q_str    pv_str;
  q_real   pv_real;
endpackage

module dut62;
  import pk62::*;

  typedef int          m_int;
  typedef int unsigned m_uint;
  typedef byte         m_byte;
  typedef shortint     m_sint;
  typedef longint      m_lint;
  typedef integer      m_integer;
  typedef time         m_time;
  typedef string       m_str;
  typedef real         m_real;
  typedef shortreal    m_sreal;
  typedef chandle      m_chandle;
  typedef event        m_event;
  typedef m_int        m_chain;    // a typedef OF an atom typedef
  typedef byte         m_unused;   // NO user anywhere
  typedef bit [7:0]    m_bit8;     // the already-supported control

  // one plain scalar user per module typedef that has one
  m_int      v_int;
  m_uint     v_uint;
  m_byte     v_byte;
  m_sint     v_sint;
  m_lint     v_lint;
  m_integer  v_integer;
  m_time     v_time;
  m_str      v_str;
  m_real     v_real;
  m_sreal    v_sreal;
  m_chandle  v_chandle;
  m_event    v_event;
  m_chain    v_chain;
  m_bit8     v_bit8;

  // and one for the package typedefs
  q_int      w_int;
  q_str      w_str;
  q_real     w_real;
  q_chain    w_chain;
  q_bit8     w_bit8;

  // a NET spelling of an atom typedef is illegal (and slang rejects a 2-state
  // `bit` net too), so every declaration here is variable-like.

  initial begin
    v_int  = 1;
    v_str  = "a";
    w_int  = 2;
    v_bit8 = 8'h3;
  end
endmodule
