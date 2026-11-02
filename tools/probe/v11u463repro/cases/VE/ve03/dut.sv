// § firstListerNamesClassTd463 (a non-generic class typedef re-exported)
package a; class K; int v; endclass typedef K kt; endpackage
package b; import a::*; export a::kt; kt h; endpackage
module top; import b::*; kt x; initial x = new; endmodule
