// § firstListerNamesClassTd463 (value-parameter class specializations)
package u; class V #(int N = 1); bit [N-1:0] x; endclass endpackage
package b; import u::*; typedef V #(4) b_v; endpackage
package a; import u::*; typedef V #(8) a_v; endpackage
module top;
endmodule
