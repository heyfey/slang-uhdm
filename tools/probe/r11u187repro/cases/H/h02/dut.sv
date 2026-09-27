// § defCloneRefsBindDefListing183 with § tpEnumCopyAtTypedef184
package p;
typedef enum logic [1:0] {A, B, C} e_t;
e_t mode = B;
parameter e_t DEF = C;
class c;
  extern function e_t get();
endclass
function e_t c::get();
  return mode == DEF ? A : mode;
endfunction
endpackage
module top; endmodule
