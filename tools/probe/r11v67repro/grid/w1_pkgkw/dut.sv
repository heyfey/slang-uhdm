// w1_pkgkw -- a SIMPLE vector typedef under every net keyword, by HOME.
// The suspect: netTypeFor's landed def-view arm EXCLUDES a Package-homed
// alias, so `wire cv_t` answers the net keyword today; aliasBind67 ignores
// the home for a SimpleType and answers 36/48.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
typedef logic [1:0] uv_t;
typedef reg   [1:0] ur_t;
module w1;
  import pk::*;
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  // package-homed SIMPLE, every net keyword
  wire  cv_t k01;
  wand  cv_t k02;
  wor   cv_t k03;
  tri   cv_t k04;
  wire  cr_t k05;
  wand  cr_t k06;
  // $unit-homed SIMPLE
  wire  uv_t k07;
  wand  uv_t k08;
  wire  ur_t k09;
  // module-local SIMPLE
  wire  lv_t k10;
  wand  lv_t k11;
  wire  lr_t k12;
  // no keyword at all
  cv_t  k13;
  cr_t  k14;
  uv_t  k15;
  lv_t  k16;
  lr_t  k17;
  // packed dim WRITTEN on the alias (IdentifierSelectName)
  wire  cv_t [1:0] k18;
  wire  lv_t [1:0] k19;
  wire  uv_t [1:0] k20;
  cv_t  [1:0] k21;
  lv_t  [1:0] k22;
  wire  lr_t [1:0] k23;
  // explicitly SCOPED
  wire  pk::cv_t k24;
  pk::cv_t k25;
  // controls with NO typedef
  wire  logic [1:0] k26;
  wand  logic [1:0] k27;
  reg   [1:0] k28;
  wire        [1:0] k29;
  // rarer net keywords over a local simple typedef
  supply0 lv_t k30;
  supply1 lv_t k31;
  tri0    lv_t k32;
  tri1    lv_t k33;
  triand  lv_t k34;
  trior   lv_t k35;
  uwire   lv_t k36;
  supply0 cv_t k37;
  uwire   cv_t k38;
endmodule
