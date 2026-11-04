// § defCloneRefsBindDefListing183 (two classes, a struct variable, a member read)
package p;
typedef struct { int a; int b; } cfg_t;
cfg_t cfg;
string name = "x";
class c1;
  function int get(); return cfg.a; endfunction
endclass
class c2;
  function string nm(); return name; endfunction
endclass
endpackage
module top; endmodule
