// § pkgArrTdImportClone250
// an importing package that re-exports the array typedefs, a third package qualified-using them, and a module importing the exporter only
package a;
  typedef logic [3:0] f_t [3];
  typedef int q_t [$];
endpackage
package b;
  import a::*;
  export a::*;
  localparam int N = 2;
  typedef f_t g_t;
endpackage
package c;
  import b::*;
  function automatic int sz(a::q_t q); return q.size(); endfunction
endpackage
module top(output logic [3:0] o);
  import b::*;
  f_t v;
  a::q_t q;
  assign v[0] = 4'd1;
  assign v[1] = 4'd2;
  assign v[2] = 4'd3;
  assign o = v[N];
  initial q.push_back(c::sz(q));
endmodule
