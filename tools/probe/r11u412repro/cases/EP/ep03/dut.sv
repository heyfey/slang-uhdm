// § extScopedParamBaseName412
package pk;
  class B #(int W = 1); bit [W-1:0] v; endclass
endpackage
package q;
  class G extends pk::B #(.W(8)); endclass
  class H extends pk::B #(4); endclass
endpackage
module test;
  q::G g;
endmodule
