// r10buvm11 arm w6 — THE DISTINGUISHER ARM.  Surelog resolves a type NAME at
// class scope against the DECLARING CLASS's own datatype map only, so a typedef
// declared INSIDE the class is `found` (and takes the DummyType/typedef arm of
// ElaborationStep::makeVar_, which mints a bit_var with NO ranges) while a
// typedef declared in the enclosing PACKAGE is not found (and takes the
// `(found == false) && tps` arm, the ONLY arm that hands the element var the
// array's own range vector).  If that split is real, this arm shows it; if it
// is not, the law is the element KIND alone.  MEASUREMENT ONLY.
package pk11e;
  typedef bit       pb_t;      // typedef in the PACKAGE
  typedef bit [7:0] pbv_t;
  class w6_base;
    typedef bit     bb_t;      // typedef in a BASE class
  endclass
  class w6_cls extends w6_base;
    typedef bit       ib_t;    // typedef INSIDE this class
    typedef bit [7:0] ibv_t;
    typedef ib_t      i2b_t;   // a chain inside this class
    // 2-D assoc (the head's shape)
    bit          a_bit   [int][int];
    pb_t         a_pbtd  [int][int];
    pbv_t        a_pbvtd [int][int];
    ib_t         a_ibtd  [int][int];
    ibv_t        a_ibvtd [int][int];
    i2b_t        a_i2btd [int][int];
    bb_t         a_bbtd  [int][int];
    pk11e::pb_t  a_qptd  [int][int];
    // FIXED
    bit          f_bit   [4];
    pb_t         f_pbtd  [4];
    ib_t         f_ibtd  [4];
    bb_t         f_bbtd  [4];
  endclass
endpackage
module w6v_cltd11_top;
  pk11e::w6_cls u = new();
endmodule
