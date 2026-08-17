// r10buvm3 arm 2 — the MEMBER-KIND grid of a CLASS-scope aggregate typedef.
// Every cell is a member of a typedef declared INSIDE a class (the position
// `buildClassTypedefTs` builds with bypassTypedefShare = 1).  Only the two
// STRUCT-typedef cells are named by § aggMemberStructTdSharesListing3; the
// other eight are the over-fire controls.
package q;

typedef class kh;
typedef struct {int a; string b;}                us_t;   // unpacked struct td
typedef struct packed {logic [3:0] a; logic [3:0] b;} ps_t;   // packed struct td
typedef union packed {logic [7:0] u; logic [7:0] v;} un_t;    // packed union td
typedef enum {E0, E1}                            en_t;   // enum td
typedef logic [15:0]                             vec_t;  // vector td
typedef vec_t                                    vecal_t;// alias-of-alias
typedef logic [3:0]                              arr_t [4]; // unpacked-array td
class kh;
endclass

class own;
  // --- STRUCT container (buildStructTs) -------------------------------
  typedef struct {
    us_t   c_us;      // NAMED: unpacked struct typedef
    ps_t   c_ps;      // NAMED: packed struct typedef
    un_t   c_un;      // control: union typedef
    en_t   c_en;      // control: enum typedef
    vec_t  c_vec;     // control: vector typedef
    vecal_t c_val;    // control: alias-of-alias
    arr_t  c_arr;     // control: unpacked-array typedef
    kh     c_kh;      // control: class handle
    logic [7:0] c_lg; // control: anonymous vector
    struct {int z;} c_anon;   // control: anonymous inline struct
  } sbox_t;
  sbox_t m_sbox;

  // --- UNION container (buildUnionTs, the SECOND call site) ------------
  typedef union packed {
    ps_t   u_ps;      // NAMED: packed struct typedef (union members must be packed)
    un_t   u_un;      // control
    logic [7:0] u_vec2;  // control
    logic [7:0] u_lg; // control
  } ubox_t;
  ubox_t m_ubox;

  // --- a struct typedef declared in the SAME CLASS as the member -------
  typedef struct {int k;} local_t;
  typedef struct {
    local_t c_local;  // class-LOCAL struct typedef member
    string  c_s;
  } lbox_t;
  lbox_t m_lbox;

  // --- containers OF the class typedef --------------------------------
  sbox_t m_sq[$];
  sbox_t m_sa[string];
  sbox_t m_sd[];
  sbox_t m_sf[3];
endclass
endpackage
