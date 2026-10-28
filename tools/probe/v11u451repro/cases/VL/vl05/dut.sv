// § pkgDupSignalLeftoverNet451
package a; typedef enum logic [1:0] {X0, X1} e_t; e_t ve [2]; typedef struct packed { logic [3:0] f; } s_t; s_t vs [3]; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; import a::*; initial ve[0] = X1; endmodule
