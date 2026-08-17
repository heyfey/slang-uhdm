// r10buvm3 arm 1 — the HEAD shape, reduced from uvm_pkg.sv:11400/11964.
// A PACKAGE-scope UNPACKED struct typedef used as the TYPE OF A MEMBER of a
// CLASS-scope struct typedef.  Golden binds the member's ref_typespec to the
// package typedef's own named struct_typespec; we mint a bare logic_typespec.
package p;

typedef class ow;
typedef struct {ow m_type;
                string m_type_name;} pair_t;

typedef struct packed {logic [3:0] a;
                       logic [3:0] b;} ppair_t;

class ow;
endclass

class f;
  // A1 — THE HEAD: unpacked pkg struct typedef as a class-struct member.
  typedef struct  {
    pair_t orig;
    string alias_type_name;
    string full_inst_path;
  } alias_t;
  protected alias_t m_inst_aliases[$];

  // A2 — the PACKED twin of A1.
  typedef struct  {
    ppair_t porig;
    string pname;
  } palias_t;
  protected palias_t m_p_aliases[$];

  // A3 — plain logic member control (must not move).
  typedef struct  {
    logic [7:0] lo;
    string nm;
  } lalias_t;
  protected lalias_t m_l_aliases[$];

  // A4 — the same pkg typedef as a plain CLASS PROPERTY (already correct today).
  protected pair_t m_one_pair;
  // A5 — queue / assoc / dynarray of the pkg typedef, direct property.
  protected pair_t m_pair_q[$];
  protected pair_t m_pair_a[string];
  protected pair_t m_pair_d[];
endclass
endpackage
