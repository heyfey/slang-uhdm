// § clsTdClsEnumMemberShares235
package p;
virtual class pol;
  typedef enum {NEVER, STARTED, FINISHED} rs_e;
endclass
class cmp extends pol;
  typedef struct {
     rs_e state;
     bit ret_val;
  } si_t;
  si_t m_one;
endclass
endpackage
module top;
endmodule
