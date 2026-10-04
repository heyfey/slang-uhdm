// § clsTdClsEnumMemberShares235
package p;
virtual class pol;
  typedef enum {NEVER, STARTED, FINISHED} rs_e;
endclass
class cmp extends pol;
  rs_e st;
  typedef struct {
     pol::rs_e state;
     bit ret_val;
  } si_t;
  si_t m_one;
endclass
endpackage
module top;
endmodule
