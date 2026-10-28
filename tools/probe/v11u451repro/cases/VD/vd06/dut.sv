// § diamondImportListsPerPath451
package a; class C; int m; endclass typedef struct packed { logic [1:0] f; } s_t; C hc; s_t sv; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; function int get(); return sv.f; endfunction endpackage
module top; import c::*; initial $display(get()); endmodule
