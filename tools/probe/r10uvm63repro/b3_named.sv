// r10uvm63 arm b3 — INDEX TYPES WRITTEN AS A NAME, plus the multi-dimensional
// (marker-range) form.
//
// Two independent reasons this arm is separate from b1:
//
//  1. § arrayElemTdClone42's INDEX HALF already runs on this path
//     (`assocIndexTs` -> `sharedAliasTs` -> `tdVecNamedClone42`), so a typedef
//     index does NOT reach the `PredefinedIntegerType` arm at all.  Whether
//     golden signs the CLONE is a different cell from whether it signs the bare
//     keyword object, and the two must be measured apart or a fix aimed at one
//     will silently fire on the other.
//  2. The INNER dimensions of a multi-dim assoc array are NOT the
//     vpiIndexTypespec: they ride the marker range's `STRING:associative`
//     constant's own vpiTypespec (`emitAssocDims`, the second call site).  If
//     the law is a property of THE INDEX POSITION it must hold there too; if it
//     is a property of the vpiIndexTypespec SLOT it must not.
typedef int          td_int_t;
typedef integer      td_integer_t;
typedef byte         td_byte_t;
typedef bit [7:0]    td_bv_t;
typedef logic [15:0] td_lv_t;
typedef enum {EA, EB} td_enum_t;
typedef struct packed { bit a; bit b; } td_st_t;
typedef td_int_t     td_chain_t;

class b3dummy;
  int x;
endclass

class b3c;
  int f01_tdint[td_int_t];
  int f02_tdinteger[td_integer_t];
  int f03_tdbyte[td_byte_t];
  int f04_tdbv[td_bv_t];
  int f05_tdlv[td_lv_t];
  int f06_tdenum[td_enum_t];
  int f07_tdstruct[td_st_t];
  int f08_tdchain[td_chain_t];
  int f09_cls[b3dummy];
  int f10_md_si[string][integer];
  int f11_md_is[integer][string];
  int f12_md_ii[integer][int];
  int f13_md_sb[string][byte];
endclass

module b3_top;
  int g01_tdint[td_int_t];
  int g02_tdinteger[td_integer_t];
  int g03_tdbyte[td_byte_t];
  int g04_tdbv[td_bv_t];
  int g05_tdlv[td_lv_t];
  int g06_tdenum[td_enum_t];
  int g07_tdstruct[td_st_t];
  int g08_tdchain[td_chain_t];
  int g09_cls[b3dummy];
  int g10_md_si[string][integer];
  int g11_md_is[integer][string];
  int g12_md_ii[integer][int];
  int g13_md_sb[string][byte];
  b3c h;
  initial h = new();
endmodule
