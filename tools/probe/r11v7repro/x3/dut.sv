// v11u7 arm x3 — TYPE KEYS (unqualified: slang rejects a package-qualified one
// as "not a valid assignment pattern member name or type").  ExprEval matches a
// key that names no field by TYPESPEC KIND (templates/ExprEval.cpp:845-852) and
// `recursiveFlattening` KEEPS the tagged_pattern wrapper for any key typespec
// that is neither int, integer nor string (653-746, the switch's default).
// `memberValue7` matches by NAME then POSITIONALLY and always drops the wrapper.
typedef struct packed { int unsigned DAT; } bus_t;
typedef struct packed { bus_t BUS; int unsigned SCA; } cfg_t;
typedef logic [7:0] byte_t;
typedef struct packed { bus_t BUS; byte_t B; } mix_t;
interface tif #(parameter cfg_t CFG = '{bus_t: '{DAT: 32}, int unsigned: 9});
  localparam int unsigned W = CFG.BUS.DAT;
  logic [W-1:0] d;
endinterface
interface mif #(parameter mix_t M = '{bus_t: '{DAT: 32}, byte_t: 8'h5A});
  localparam int unsigned W = M.BUS.DAT;
  logic [W-1:0] d;
endinterface
module leaf (tif p, output logic o);
  assign o = p.d[0];
endmodule
module mleaf (mif p, output logic o);
  assign o = p.d[0];
endmodule
module top (output logic o, output logic o2);
  tif u ();
  mif m ();
  leaf  a0 (.p(u), .o(o));
  mleaf b0 (.p(m), .o(o2));
endmodule
