// r10buvm34repro/g34a2.sv — ARM 2: LOOP-VARIABLE LIST ARITY x WRITTEN FORM.
// [i] / [i,j] / [,j] / [i,] / [i,j,k] / [,,k] over a 3-D array, written
// `C::a`, bare, DOTTED (`obj.a`, a hier_path — § foreachHierPathAlwaysRes21)
// and HIERARCHICAL, so the skipped-slot placeholders and the multi-dim arms
// are read position by position.  MEASUREMENT ONLY.
package q34;

  class holder34;
    typedef holder34 this_type;
    static int s3d34 [2][3][4];      // 3-D fixed, STATIC (scopable)
    static int s2d34 [2][3];         // 2-D fixed, STATIC
    static int sq34  [$];            // 1-D queue, STATIC
    int i3d34 [2][3][4];             // 3-D fixed, instance
    int i2d34 [2][3];                // 2-D fixed, instance
    extern function void oob34();
  endclass

  function void holder34::oob34();
    int r34;
    holder34 h34;
    // ---- SCOPED, every arity ---------------------------------------------
    foreach (this_type::sq34 [i])      r34 = i;        // S1  [i]
    foreach (this_type::s2d34[i,j])    r34 = i+j;      // S2  [i,j]
    foreach (this_type::s2d34[ ,j])    r34 = j;        // S3  [,j]
    foreach (this_type::s2d34[i, ])    r34 = i;        // S4  [i,]
    foreach (this_type::s3d34[i,j,k])  r34 = i+j+k;    // S5  [i,j,k]
    foreach (this_type::s3d34[ , ,k])  r34 = k;        // S6  [,,k]
    foreach (this_type::s3d34[i, ,k])  r34 = i+k;      // S7  [i,,k]
    // ---- BARE, every arity (the resolvable controls) ---------------------
    foreach (sq34 [i])                 r34 = i;        // B1
    foreach (s2d34[i,j])               r34 = i+j;      // B2
    foreach (s2d34[ ,j])               r34 = j;        // B3
    foreach (s2d34[i, ])               r34 = i;        // B4
    foreach (s3d34[i,j,k])             r34 = i+j+k;    // B5
    foreach (s3d34[ , ,k])             r34 = k;        // B6
    foreach (s3d34[i, ,k])             r34 = i+k;      // B7
    // ---- DOTTED (a hier_path array reference) ----------------------------
    foreach (h34.i2d34[i,j])           r34 = i+j;      // D1
    foreach (h34.i3d34[ , ,k])         r34 = k;        // D2
    // ---- `this.` prefixed ------------------------------------------------
    foreach (this.i2d34[i,j])          r34 = i+j;      // T1
  endfunction

endpackage

module top34a2;
  import q34::*;
  int m2d34 [2][3];
  initial begin
    // MODULE home
    foreach (q34::holder34::s2d34[i,j]) m2d34[i][j] = i+j;   // M1 3-segment scoped
    foreach (q34::holder34::s2d34[ ,j]) m2d34[0][j] = j;     // M2 scoped, skipped
    foreach (m2d34[i,j])                m2d34[i][j] = i+j;   // M3 bare control
    foreach (m2d34[ ,j])                m2d34[0][j] = j;     // M4 bare, skipped
  end
endmodule
