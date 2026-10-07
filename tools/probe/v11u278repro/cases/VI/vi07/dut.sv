// § ifaceElabTypeParamIsDefObj278
interface ifc #(parameter type T = logic [3:0]) ();
  function automatic T inc(T a); return a + 1; endfunction
  T v;
  assign v = inc(4'd3);
endinterface
module top(output logic [3:0] o);
  ifc u();
  assign o = u.v;
endmodule
