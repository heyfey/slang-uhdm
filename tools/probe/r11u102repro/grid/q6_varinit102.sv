// r11u102 arm q6 — LAW B on a VARIABLE declaration's initializer, which this
// emitter lists as a net-decl-assign cell exactly like a net's.
package q6p;
  function automatic int fp(int a); return a ** 2; endfunction
  function automatic int fs(int a); return a + 1; endfunction
  localparam int P512 = 512;
endpackage
module q6_varinit102 (output logic [63:0] o);
  logic signed [63:0] vFP = q6p::fp(3);
  logic        [63:0] vFS = q6p::fs(4);
  reg          [7:0]  vCL = $clog2(q6p::P512);
  int                 vI  = q6p::fp(3);
  bit          [15:0] vB  = q6p::fs(4);
  integer             vG  = $clog2(q6p::P512);
  assign o = vFP ^ vFS ^ {56'b0, vCL} ^ {32'b0, vI} ^ {48'b0, vB} ^ {32'b0, vG};
endmodule
