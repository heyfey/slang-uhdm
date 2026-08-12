// r10svs6 arm b3 — the DIMENSION grid: every way of writing the fixed size, the
// 2-D case, and the FIXED/UNSIZED HYBRIDS (which decide whether the new fixed
// branch may be reached at all for a declaration that also carries a `[]`/`[$]`/
// `[idx]` dim — slang's canonical type for `int x[4][]` is a
// FixedSizeUnpackedArrayType OF a DynamicArrayType, so the gate order between the
// two arms is a real question and not a stylistic one).
class b3_cls;
  int c01_size[4];       // [N] size form
  int c02_rng03[0:3];    // ascending range
  int c03_rng30[3:0];    // descending range
  int c04_rng14[1:4];    // non-zero-based
  int c05_2d[4][2];      // 2-D fixed
  int c06_fixdyn[4][];   // fixed OF dynamic
  int c07_dynfix[][4];   // dynamic OF fixed
  int c08_fixq[4][$];    // fixed OF queue
  int c09_fixassoc[4][string];
  int c10_qfix[$][4];
endclass

class b3_par #(int N = 4);
  int c11_paramsz[N];    // dim sized by a class type parameter
  int c12_lit[4];        // control in the same parameterized class
endclass

module b3_top;
  parameter int P = 4;
  int m01_size[4];
  int m02_rng03[0:3];
  int m03_rng30[3:0];
  int m04_rng14[1:4];
  int m05_2d[4][2];
  int m06_fixdyn[4][];
  int m07_dynfix[][4];
  int m11_paramsz[P];
  b3_cls c;
  b3_par #(4) p;
endmodule
