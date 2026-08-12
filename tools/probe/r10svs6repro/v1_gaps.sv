// r10svs6 VERIFIER arm v1 — EMPTY PRODUCT CELLS the implementer's 105-cell grid
// SKIPS, on the ELEMENT-KIND and DIMENSION axes.  Every cell here is a
// declaration whose canonical type is (or looks like) a FixedSizeUnpackedArray
// class property and which the b1..b5 arms never wrote.
//
// THE TWO THAT MATTER MOST, and why:
//   v01_tdarr — `typedef byte b4_t[4]; b4_t x[2];`  The gate's clause (2) tests
//     `cp.getType().kind != TypeAlias` on the PROPERTY's OWN type, which here is
//     a FixedSizeUnpackedArrayType (the OUTER `[2]`), so the arm FIRES; but the
//     canonical descent runs through BOTH dims to `byte`, while
//     § fixedUnpackedCount6 and buildUnpackedRanges both read the WRITTEN SYNTAX
//     dims, of which there is exactly ONE.  vpiSize/vpiRange are therefore
//     computed over a different dimension set than the element.  Untested.
//   v04_prange — a PARAM-sized RANGE `[N-1:0]`, not the `[N]` form cell
//     c11_paramsz measured.  The `PARAM-sized dim contributes 1` quirk is stated
//     for `[N]`; a param RANGE is a different syntax node.
typedef byte b4_t[4];
typedef int dyn_t[];
typedef struct packed signed { byte a; byte b; } sps_t;
typedef union { int a; byte b; } uun_t;

class v1_other;
  int q;
endclass

class v1_par #(int N = 4, type T = int);
  int    v04_prange[N-1:0];   // PARAM-sized RANGE dim (c11 measured `[N]` only)
  T      v12_tpelem[4];       // type-parameter ELEMENT, fixed dim
  int    v14_parlit[N];       // control: the measured `[N]` form, same class
endclass

class v1_cls;
  b4_t   v01_tdarr[2];        // fixed array OF a whole-array typedef
  int    v02_3d[2][3][4];     // THREE dims (grid stops at 2)
  int    v03_mix[0:3][2];     // MIXED range dim + size dim
  uun_t  v05_uunion[4];       // unpacked UNION element (grid has struct only)
  event  v06_ev[4];           // event element — named_event arm is scalar-only
  bit [3:0][7:0] v07_pk[4];   // 2-D PACKED element
  dyn_t  v08_tddyn[4];        // fixed OF a typedef'd DYNAMIC array
  v1_cls v09_self[4];         // SELF-referential class handle element
  sps_t  v13_spsigned[4];     // signed PACKED STRUCT element (§ 8 clause b)
  real   v11_rt[4];           // realtime canonicalises to real — control
  int    v15_ord_a;           // ORDER control: scalar before
  int    v15_arr[4];          //   the array between two scalars
  int    v15_ord_b;           // ORDER control: scalar after
endclass

module v1_top;
  parameter int P = 4;
  b4_t   m01_tdarr[2];
  int    m02_3d[2][3][4];
  int    m03_mix[0:3][2];
  uun_t  m05_uunion[4];
  bit [3:0][7:0] m07_pk[4];
  sps_t  m13_spsigned[4];
  v1_cls c;
  v1_par #(4, int) p;
endmodule
