// § namedUnlinkedWrittenOrder207: named calls with string, real and enum formals, a skipped string default and the list reordered, in an out-of-body task
package p;
typedef enum {R, G, B} col_t;
class F;
  extern function string mt(string s, col_t c = G, real r = 1.5, string t = "d");
  extern task tk();
endclass
task F::tk();
  string x;
  x = mt(.t("z"), .s("a"));
  x = mt(.r(2.0), .c(B), .s(x));
  x = mt(.s(x), .t(mt(.s("in"), .r(0.5))));
endtask
function string F::mt(string s, col_t c = G, real r = 1.5, string t = "d");
  return {s, t};
endfunction
endpackage
module top; endmodule
