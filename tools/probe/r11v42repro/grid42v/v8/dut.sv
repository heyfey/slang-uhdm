// v11u42 arm v8 — settle the two REFUTED gates:
//  (A) which INITIALISER shapes make golden keep the identifier;
//  (B) unqualified reads inside a package that only IMPORTS the parameter,
//      and the MIXED-builder site inside a declaring package.
package pa8;
  localparam int unsigned LP      = 8;
  localparam int unsigned CAT     = {2'b10, 2'b01};
  localparam int unsigned CATADD  = {2'b10, 2'b01} + 0;
  localparam int unsigned CATPAR  = ({2'b10, 2'b01});
  localparam int unsigned CATCOND = (1) ? {2'b10, 2'b01} : 4;
  localparam int unsigned RELCAT  = CAT;          // relay OF a concat param
  localparam int unsigned RELCATQ = pa8::CAT;     // qualified relay
  localparam int unsigned REPADD  = {2{2'b01}} - 0;
  localparam int unsigned CATCALL = $clog2({2'b10, 2'b01});
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
endpackage

package pb8;
  import pa8::*;
  function automatic logic f_imp(pa8::s_t a);
    return a.m[LP-1];            // c01 UNQUALIFIED read of an IMPORTED pkg param, inside a package
  endfunction
endpackage

package pc8;
  localparam int unsigned LP = 8;
  typedef struct packed { logic [15:0] m; logic [3:0] t; } s_t;
  function automatic logic f_mix(s_t arr [0:1]);
    return arr[0].m[LP-1];       // c02 MIXED builder (select on the base) inside the declaring package
  endfunction
  function automatic logic f_mixq(s_t arr [0:1]);
    return arr[0].m[pc8::LP-1];  // c03 MIXED builder, QUALIFIED, inside the declaring package
  endfunction
endpackage

module v8 (input logic [19:0] w20, output logic [63:0] o);
  pa8::s_t v;
  pc8::s_t ar [0:1];
  assign v = w20;
  assign ar[0] = w20; assign ar[1] = w20;
  assign o[0] = v.m[pa8::CAT-1];      // c04 concat init
  assign o[1] = v.m[pa8::CATADD-1];   // c05 concat inside a binop
  assign o[2] = v.m[pa8::CATPAR-1];   // c06 parenthesised concat
  assign o[3] = v.m[pa8::CATCOND-1];  // c07 concat inside a conditional
  assign o[4] = v.m[pa8::RELCAT-1];   // c08 relay of a concat param
  assign o[5] = v.m[pa8::RELCATQ-1];  // c09 qualified relay of a concat param
  assign o[6] = v.m[pa8::REPADD-1];   // c10 replication inside a binop
  assign o[7] = v.m[pa8::CATCALL-1];  // c11 concat inside a system call
  assign o[8] = pb8::f_imp(v);
  assign o[9] = pc8::f_mix(ar);
  assign o[10] = pc8::f_mixq(ar);
  assign o[11] = ar[0].m[pc8::LP-1];  // c12 mixed builder in a module (landed law control)
endmodule
