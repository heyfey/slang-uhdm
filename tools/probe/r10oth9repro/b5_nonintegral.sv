// r10oth9 arm b5 — NON-INTEGRAL ELEMENTS, where the array_var gets nothing and
// the element typespec must therefore be left exactly as it is.
//
// These are the cells an over-wide law shows up in.  A signed PACKED STRUCT and
// a SIGNED ENUM are the sharp ones: both are `isSigned()`-true and both get the
// array_var NOTHING (r10oth8 a5 d01/d09), so a predicate of "signed" without the
// kind list over-fires here.  string / real / class-handle elements are the
// loud cells: one side may emit no typespec object at all, which is a DIFFERENT
// and louder reading than a missing field.
//
// `rand` is deliberately absent on the string / real / handle cells: slang
// rejects `rand string x[]` and `rand real x[]` outright (LRM), which would make
// the arm unparseable on our side only.
typedef enum { P0, P1 }                        e_t;
typedef enum bit signed [3:0] { Q0, Q1 }       es_t;
typedef struct packed { byte hi; byte lo; }    sp_t;
typedef struct packed signed { byte hi; byte lo; } sps_t;
typedef struct { byte hi; byte lo; }           su_t;

class jc;
  rand e_t               j01_enum[];
  rand es_t              j02_enums[];
  rand sp_t              j03_struct[];
  rand sps_t             j04_structs[];
  su_t                   j05_ustruct[];
  string                 j06_string[];
  real                   j07_real[];
  jc                     j08_handle[];
  chandle                j09_chandle[];
endclass

module b5_top;
  e_t                    k01_enum[];
  es_t                   k02_enums[];
  sp_t                   k03_struct[];
  sps_t                  k04_structs[];
  su_t                   k05_ustruct[];
  string                 k06_string[];
  real                   k07_real[];
  jc                     k08_handle[];
  chandle                k09_chandle[];
  jc h;
  initial h = new();
endmodule
