// VERIFIER arm — the class has NO home package ($unit scope).  classBodyHomePkg75
// is null there, so the site cannot fire.  Does golden mint a wire anyway?
class c76u;
  typedef enum {U_A, U_B} u76_t;
  u76_t m;
  extern function int oobf(int k);
endclass
function int c76u::oobf(int k);
  int r;
  r = 0;
  if (m == U_A) r = r + 1;
  return r + k;
endfunction
module top76u;
  c76u c;
  int r;
  initial begin c = new(); r = c.oobf(1); end
endmodule
