// § tpProtoRetDefaultTs432
package pk;
class C #(type T = byte);
extern static function T f();
endclass
function C::T C::f();
return 3;
endfunction
endpackage
module top;
  initial $display(pk::C#()::f());
endmodule
