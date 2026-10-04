// § clsTdClsEnumMemberShares235
package p;
class pol;
  typedef enum logic [1:0] {NEVER, STARTED, FINISHED} rs_e;
endclass
typedef union packed {
   pol::rs_e state;
   logic [1:0] raw;
} su_t;
su_t m_one;
endpackage
module top;
endmodule
