// § pkgDupSignalLeftoverNet451
package a; class C; endclass C ca [2]; C cb; string sa [4]; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; endmodule
