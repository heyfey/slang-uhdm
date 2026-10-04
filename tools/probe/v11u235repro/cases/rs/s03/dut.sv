// § clsTdClsEnumMemberShares235
class pol;
  typedef enum {X, Y} rs_e;
endclass
class cmp extends pol;
  typedef struct { rs_e state; int n; } si_t;
  si_t a;
endclass
module top;
  initial begin cmp c; c = new; end
endmodule
